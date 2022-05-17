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

require 'fluent/plugin/viaq_data_model_flatten_labels'


class ViaqDataModelFilterTest < Test::Unit::TestCase
    include ViaqDataModel::FlattenLabels

    setup do
        @openshift_sequence = 1
    end

    sub_test_case '#flatten_labels' do

        test 'should return the record if it is missing labels' do
            record = {"foo" => "bar"}
            assert_equal({"foo" => "bar"}, flatten_labels(record))
        end

        test "should convert the label set into an array of key=value" do
            record = {"kubernetes" => { "labels" => { "foo" => "bar", "abc" => "123"}}}
            exp = {"kubernetes" => { "flat_labels" => ["foo=bar", "abc=123"]}}
            assert_equal(exp, flatten_labels(record))
        end

        test "should exclude the exclusions from flattening and remove the flattened" do
            record = {"kubernetes" => { "labels" => { "foo" => "bar", "abc" => "123"}}}
            exp = {"kubernetes" => { "labels" => {"abc" => "123"}, "flat_labels" => ["foo=bar"]}}
            assert_equal(exp, flatten_labels(record, ['abc']))
        end
    end
end