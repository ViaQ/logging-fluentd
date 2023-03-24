require "test_helper"
require "fluent/plugin/out_remote_syslog"

class RemoteSyslogOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::RemoteSyslogOutput).configure(conf)
  end

  def test_configure
    d = create_driver %[
      @type remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      program minitest
    ]

    loggers = d.instance.instance_variable_get(:@senders)
    assert_equal loggers, []

    assert_equal "example.com", d.instance.instance_variable_get(:@host)
    assert_equal 5566, d.instance.instance_variable_get(:@port)
    assert_equal "debug", d.instance.instance_variable_get(:@severity)
  end

  def test_write
    d = create_driver %[
      @type remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      program minitest

      rfc rfc3164

      <format>
        @type single_value
        message_key message
      </format>
    ]

    mock.proxy(RemoteSyslogSender::UdpSender).new("example.com", 5566, whinyerrors: true, program: "minitest") do |sender|
      packet_option = {}.tap do |po|
        {facility: "user", severity: "debug", program: "minitest", hostname: "foo.com", rfc: :rfc3164}.each do|k,v|
          po[k.to_sym] = v
        end
        po
      end
      mock.proxy(sender).transmit("foo",  packet_option)
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo"})
    end
  end

  def test_write_tcp_rfc3164
    d = create_driver %[
      @type remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      program minitest

      protocol tcp

      rfc rfc3164

      <format>
        @type single_value
        message_key message
      </format>
    ]

    any_instance_of(RemoteSyslogSender::TcpSender) do |klass|
      mock(klass).connect
    end

    factory_args = {}
    {whinyerrors: true, program: "minitest", tls: false, packet_size: 1024, timeout: nil, timeout_exception: false, keep_alive: false, keep_alive_cnt: nil, keep_alive_idle: nil, keep_alive_intvl: nil}.each do |k,v|
      factory_args[k.to_sym] = v
    end
    mock.proxy(RemoteSyslogSender::TcpSender).new("example.com", 5566, factory_args) do |sender|
      packet_options = {}
      {facility: "user", severity: "debug", program: "minitest", hostname: "foo.com", rfc: :rfc3164}.each do |k,v|
          packet_options[k.to_sym] = v
      end
      mock(sender).transmit("foo",  packet_options)
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo"})
    end
  end

  def test_write_tcp_rfc5424
    d = create_driver %[
      @type remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      appname minitest
      procid  miniproc
      msgid   minimsg

      protocol tcp

      rfc rfc5424

      <format>
        @type single_value
        message_key message
      </format>
    ]

    any_instance_of(RemoteSyslogSender::TcpSender) do |klass|
      mock(klass).connect
    end

    factory_args = {}
    {whinyerrors: true, program: "fluentd", tls: false, packet_size: 1024, timeout: nil, timeout_exception: false, keep_alive: false, keep_alive_cnt: nil, keep_alive_idle: nil, keep_alive_intvl: nil}.each do |k,v|
      factory_args[k.to_sym] = v
    end
    mock.proxy(RemoteSyslogSender::TcpSender).new("example.com", 5566, factory_args) do |sender|
      packet_options = {}
      {facility: "user", severity: "debug", appname: "minitest", procid: "miniproc", msgid: "minimsg", program: "fluentd", hostname: "foo.com", rfc: :rfc5424}.each do |k,v|
          packet_options[k.to_sym] = v
      end
      mock(sender).transmit("foo",  packet_options)
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo"})
    end
  end
end
