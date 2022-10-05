#
# Fluentd Viaq Data Model Filter Plugin - Ensure records coming from Fluentd
# use the correct Viaq data model formatting and fields.
#
# Copyright 2022 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#require_relative '../helper'
require 'fluent/test'
require 'test/unit/rr'

require 'fluent/plugin/viaq_data_model_openshift'


class ViaqDataModelFilterTest < Test::Unit::TestCase
    include ViaqDataModel::OpenShift

    setup do
        @openshift_sequence = 1
    end

    sub_test_case '#add_cluster_id' do

        test 'should add the cluster id when then env variable is present' do
            begin
              ENV['OPENSHIFT_CLUSTER_ID'] = 'abc123'
              openshift = {"foo" => "bar"}
              record = {"openshift" => openshift}
              add_cluster_id(record)
              assert_equal({"cluster_id" => "abc123", "foo" => "bar"}, record['openshift'])

              record = {}
              add_cluster_id(record)
              assert_equal({"cluster_id" => "abc123"}, record['openshift'])
            ensure
                ENV.delete('OPENSHIFT_CLUSTER_ID')
            end
        end

        test 'should silently proceed when then env variable is not present' do
            record = {"openshift" => {"foo" => "bar"}}
            add_cluster_id(record)
            assert_equal(record,{"openshift" => {"foo" => "bar"}})
        end

    end

    sub_test_case '#add_openshift_data' do

        test 'should add the openshift hash if it does not exist' do
            assert_nothing_raised do
                record = {"message" => "20210909T12:15:09 Warning Some Warning message"}
                add_openshift_data(record)
                assert_true(record['openshift']['sequence'] > 0, "Expected openshift hash to be created and the sequence number populated")
            end
        end
        
        test "should add the sequence number to the openshift hash if it does not exist" do
            record = {"message" => "20210909T12:15:09 Warning Some Warning message", "openshift" => {}}
            add_openshift_data(record)
            assert_true(record['openshift']['sequence'] > 0, "Expected the sequence number populated")
        end
        test "should not modify the sequence number to the openshift hash if it does exist" do
            recordOne = {"message" => "20210909T12:15:09 Warning Some Warning message", "openshift" => {}}
            recordTwo = {"message" => "20210909T12:15:09 Warning Some Warning message", "openshift" => {}}
            add_openshift_data(recordOne)
            add_openshift_data(recordTwo)
            assert_true(recordTwo['openshift']['sequence'] > recordOne['openshift']['sequence'], "Expected the sequence number to increment")
        end
        
        test "should restart the sequence when it reaches max value" do
            @openshift_sequence = MAX_SEQUENCE
            recordOne = {"message" => "20210909T12:15:09 Warning Some Warning message", "openshift" => {}}
            recordTwo = {"message" => "20210909T12:15:09 Warning Some Warning message", "openshift" => {}}
            add_openshift_data(recordOne)
            add_openshift_data(recordTwo)
            assert_equal(1, recordTwo['openshift']['sequence'], "Exp. the sequence number to roll over")
        end

    end
end