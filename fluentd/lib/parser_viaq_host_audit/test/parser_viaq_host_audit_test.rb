require 'fluent/test'
require 'test/unit/rr'
require 'fluent/test/driver/parser'
require 'json'

require_relative '../lib/fluent/plugin/parser_viaq_host_audit'

class ParserViaqHostAuditTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
  end

  def create_driver(conf = '')
    Fluent::Test::Driver::Parser.new(ViaqHostAuditParser).configure(conf)
  end

  sub_test_case 'plugin will parse auditd messages' do
    test 'audit time is not the second field' do
      d = create_driver()
      message = "node=[somenode.com|http://somenode.com/] type=NETFILTER_CFG msg=audit(1644924200.294:43342801): table=nat:2;KUBE-SEP-G4T6AO6PAPRFVIHV:5576818034 family=2 entries=1330502105 op=nft_register_rule pid=93144 subj=system_u:system_r:spc_t:s0 comm=\"iptables-restor\""
      d.instance.parse(message) do |time, record|
        assert_equal('NETFILTER_CFG', record['audit.linux']['type'])
        assert_equal('43342801', record['audit.linux']['record_id'])
        assert_equal("2022-02-15T11:23:20.293999+00:00", record['time'])
        assert_equal(message, record['message'])
        assert_true(time.instance_of? Fluent::EventTime)
      end
    end
    test 'service_start is detected' do
      d = create_driver()
      message = "type=SERVICE_START msg=audit(1571910991.146:296): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=fprintd comm=\"systemd\" exe=\"/usr/lib/systemd/systemd\" hostname=? addr=? terminal=? res=success'UID=\"root\" AUID=\"unset\""
      d.instance.parse(message) do |time, record|
        assert_equal('SERVICE_START', record['audit.linux']['type'])
        assert_equal('296', record['audit.linux']['record_id'])
        assert_equal("2019-10-24T09:56:31.145999+00:00", record['time'])
        assert_equal(message, record['message'])
        assert_true(time.instance_of? Fluent::EventTime)
      end
    end
    test 'AVC denial is detected' do
      d = create_driver()
      message = "type=AVC msg=audit(1571910991.146:233): avc:  denied  { read } for  pid=2234 comm=\"gdm-session-wor\" scontext=system_u:system_r:xdm_t:s0-s0:c0.c1023 tcontext=system_u:system_r:kernel_t:s0 tclass=key permissive=0
"
      d.instance.parse(message) do |time, record|
        assert_equal('AVC', record['audit.linux']['type'])
        assert_equal('233', record['audit.linux']['record_id'])
        assert_equal("2019-10-24T09:56:31.145999+00:00", record['time'])
        assert_equal(message, record['message'])
        assert_true(time.instance_of? Fluent::EventTime)
      end
    end
  end
end
