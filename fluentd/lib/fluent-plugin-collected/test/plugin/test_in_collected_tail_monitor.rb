require "test_helper"
require "fluent/plugin/in_collected_tail_monitor"
require 'net/http'
require 'uri'
require 'fileutils'

class CollectedTailMonitorInputTest < Test::Unit::TestCase
  include Fluent

  MONITOR_CONFIG = %(
      @type collected_tail_monitor
      <labels>
        tag mytag
        host example.com
      </labels>
   )

  def setup()
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::CollectedTailMonitorInput).configure(conf)
  end

  def test_configure
    create_driver(MONITOR_CONFIG)
  end

  def test_labels
    driver = create_driver(MONITOR_CONFIG)
    driver.run do
      driver.instance.update_monitor_info()
      path = '/var/log/pods/mynamespace2_mypodname2_05682f61-8a44-47af-ae0f-41ad3792e20a/mycontainername2/1.log'
      labels = driver.instance.labels({}, path)
      assert_equal('mynamespace2', labels[:namespace])
      assert_equal('mycontainername2', labels[:containername])
      assert_equal('mypodname2', labels[:podname])
      assert_equal('05682f61-8a44-47af-ae0f-41ad3792e20a', labels[:poduuid])
    end
  end

  def test_regex
    regex = Fluent::Plugin::CollectedTailMonitorInput::REGEX_LOG_PATH
    path = '/var/log/pods/mynamespace2_mypodname2_05682f61-8a44-47af-ae0f-41ad3792e20a/mycontainername2/1.log'
    assert_match(regex,path )
    assert_equal(regex.match(path).to_a,
                 [path,
                  "mynamespace2",
                  "mypodname2",
                  "05682f61-8a44-47af-ae0f-41ad3792e20a",
                  "mycontainername2"])
    refute_match(regex, '/var/log/not-a-pod.log')
  end

  # Start a fluentd process and verify metrics are published for logs.
  def test_functional
    Dir.mktmpdir do |tmpdir|
      conf_path = File.join(tmpdir, "fluent.conf")
      File.write(conf_path, %(
<source>
  @type prometheus
  bind 127.0.0.1
  port 8888
</source>

<source>
  @type prometheus_monitor
  <labels>
    hostname ${hostname}
  </labels>
</source>

# excluding prometheus_tail_monitor
# since it leaks namespace/pod info
# via file paths

# tail_monitor plugin which publishes log_collected_bytes_total
<source>
  @type collected_tail_monitor
  <labels>
    hostname ${hostname}
  </labels>
</source>

# This is considered experimental by the repo
<source>
  @type prometheus_output_monitor
  <labels>
    hostname ${hostname}
  </labels>
</source>

<source>
  @type tail
  path "#{tmpdir}/**/*.log"
  tag kubernetes.*
  <parse>
      @type none
  </parse>
</source>

<match **>
  @type null
</match>
))
      log_path = File.join(tmpdir, "fluent.log")
      pod_log = File.join(tmpdir, 'mynamespace2_mypodname2_05682f61-8a44-47af-ae0f-41ad3792e20a/mycontainername2/1.log')
      FileUtils.mkdir_p File.dirname(pod_log)
      uri = URI.parse("http://localhost:8888/metrics")
      spawn_fluentd(tmpdir, ["-c", conf_path, "-o", log_path ]) do
        Timeout.timeout(10) do
          File.write(pod_log, "hello\n")
          response = Net::HTTP.get_response(uri)
          assert_equal(response.code, '200')
          assert_match(/.*TYPE log_collected_bytes_total counter.*/, response.body)
          metrics = response.body.lines.grep(/^log_collected_bytes_total{.*/)
          if !metrics.nil? && !metrics.empty?
            assert_equal(metrics.size, 1)
            metric = metrics[0]
            assert_match(/hostname="#{Socket.gethostname}"/, metric)
            assert_match(/namespace="mynamespace2"/,metric)
            assert_match(/podname="mypodname2"/, metric)
            assert_match(/poduuid="05682f61-8a44-47af-ae0f-41ad3792e20a"/, metric)
            assert_match(/containername="mycontainername2"/, metric)
            assert_match(/} 6.0$/, metric)
          else
            raise "retry"
          end
        rescue ::Test::Unit::AssertionFailedError
          raise
        rescue Exception => e
          sleep 0.1
          retry
        end
      rescue
        if File.exist? log_path
          puts "================ fluent.log"
          puts File.read(log_path)
        end
        raise
      end
    end
  end

  def spawn_fluentd(dir, args)
    cmdname = File.expand_path(File.dirname(__FILE__) + "../../../../../vendored_gem_src/fluentd/bin/fluentd")
    gemfile = File.expand_path(File.dirname(__FILE__) + "../../../Gemfile")
    env = { "BUNDLE_GEMFILE" => gemfile }
    pid = spawn(env, "bundle", "exec", cmdname, *args, :chdir=>dir, )
    begin
      yield
    ensure
      Process.kill(:TERM, pid)
      Timeout.timeout(10) do
        Process.wait(pid)
      end
    end
  end
end
