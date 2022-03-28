require 'test_helper'
require 'fluent/plugin/in_collected_tail_monitor'

class CollectedTailMonitorInputTest < Test::Unit::TestCase
  include Fluent

  def setup
    Fluent::Test.setup
  end

  MONITOR_CONFIG = %(
    @type collected_tail_monitor
    <labels>
      foo bar
    </labels>
    )

  INVALID_MONITOR_CONFIG = %[
  @type collected_tail_monitor

  <labels>
    host ${hostname}
    foo bar
    invalid_use1 $.foo.bar
    invalid_use2 $[0][1]
  </labels>
  ]

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::CollectedTailMonitorInput).configure(conf)
  end

  def test_labels_applied_to_metrics
    d = create_driver(MONITOR_CONFIG)
    d.run do
      d.instance.update_monitor_info

      # Test /var/log/containers format
    path = '/var/log/containers/mypodname_mynamespace_mycontainername-34646d7fb38199129ab8d0e6f41833d26e1826cba92571100fd6c53904a5317e.log'
      labels = d.instance.labels({ 'plugin_id' => 'mypluginid', 'type' => 'input_plugin' }, path)
      assert_equal('mynamespace', labels[:namespace])
      assert_equal('mycontainername', labels[:containername])
      assert_equal('mypodname', labels[:podname])
      assert_equal('mypluginid', labels[:plugin_id])
      assert_equal('bar', labels[:foo])

      # Test /var/log/pods format
      path = '/var/log/pods/mynamespace2_mypodname2_05682f61-8a44-47af-ae0f-41ad3792e20a/mycontainername2/1.log'
      labels = d.instance.labels({ 'plugin_id' => 'mypluginid', 'type' => 'input_plugin' }, path)
      assert_equal('mynamespace2', labels[:namespace])
      assert_equal('mycontainername2', labels[:containername])
      assert_equal('mypodname2', labels[:podname])
      assert_equal('bar', labels[:foo])
    end
  end

  def test_invalid_configure
    assert_raise(Fluent::ConfigError) do
      create_driver(INVALID_MONITOR_CONFIG)
    end
  end

  test 'emit' do
    d = create_driver(MONITOR_CONFIG)
    d.run(timeout: 0.5)

    d.events.each do |tag, time, record|
      assert_equal('input.test', tag)
      assert_equal({ 'plugin_id' => 'fluentd', 'type' => 'tail' }, record)
      assert(time.is_a?(Fluent::EventTime))
    end
  end
end
