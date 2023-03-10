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

  def test_labels_log_pods
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

  def test_labels_log_containers
    driver = create_driver(MONITOR_CONFIG)
    driver.run do
      driver.instance.update_monitor_info()
      path = '/var/log/containers/mypodname_mynamespace_mycontainername-34646d7fb38199129ab8d0e6f41833d26e1826cba92571100fd6c53904a5317e.log'
      labels = driver.instance.labels({}, path)
      assert_equal('mypodname', labels[:podname])
      assert_equal('mynamespace', labels[:namespace])
      assert_equal('mycontainername', labels[:containername])
    end
  end

  # Start a fluentd process and verify metrics with correct labels are published.
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
      fluentd_log = File.join(tmpdir, "fluent.log")
      pod_log = File.join(tmpdir, 'pods/mynamespace2_mypodname2_05682f61-8a44-47af-ae0f-41ad3792e20a/mycontainername2/1.log')
      container_log = File.join(tmpdir, 'containers/mypodname_mynamespace_mycontainername-34646d7fb38199129ab8d0e6f41833d26e1826cba92571100fd6c53904a5317e.log')
      [pod_log, container_log].each { |f| FileUtils.mkdir_p File.dirname(f) }
      uri = URI.parse("http://localhost:8888/metrics")
      spawn_fluentd(tmpdir, ["-c", conf_path, "-q", "-o", fluentd_log]) do
        Timeout.timeout(10) do
          File.write(pod_log, "hello\n")
          File.write(container_log, "hello\n")
          response = Net::HTTP.get_response(uri) rescue retry
          assert_equal(response.code, '200')
          assert_match(/.*TYPE log_collected_bytes_total counter.*/, response.body)
          metrics = response.body.lines.grep(/^log_collected_bytes_total{/)
          redo if metrics.size < 2
          assert_metrics_include?(metrics, "mynamespace2", "mypodname2", "05682f61-8a44-47af-ae0f-41ad3792e20a", "mycontainername2")
          assert_metrics_include?(metrics, "mynamespace", "mypodname", "", "mycontainername")
        end
      end
    rescue                      # Show the fluentd log file on failure
      puts "==== fluent.log", File.read(fluentd_log), "====fluent.log ends"  if File.exist? fluentd_log
      raise
    end
  end

  def assert_metrics_include?(metrics, namespace, pod, uuid, container)
    patterns = [/hostname="#{Socket.gethostname}"/,
                /namespace="#{namespace}"/,
                /podname="#{pod}"/,
                /poduuid="#{uuid}"/,
                /containername="#{container}"/]
    assert(
      metrics.any?{|m| patterns.all?{|p| p.match(m)}},
      "No match for [#{namespace}, #{pod}, #{uuid}, #{container}] in \n#{metrics.join}")
  end

  def spawn_fluentd(dir, args)
    cmdname = "fluentd"
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
