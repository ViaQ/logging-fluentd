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
require 'ostruct'

require 'fluent/plugin/viaq_data_model_elasticsearch_index_name'


class ViaqDataModelFilterTest < Test::Unit::TestCase
    
    include ViaqDataModel::ElasticsearchIndexName

    setup do
        @logs = []
        @src_time_name = '@timestamp'
        @dest_time_name = '@timestamp'
        @orphaned_namespace_name = '.orphaned'
        @elasticsearch_index_name_field = 'viaq_index_name'
        @elasticsearch_index_prefix_field = 'viaq_index_name'
        @rec = {
            "@timestamp" => '2017-07-27T17:27:46.216527+00:00',
            "message" => "My life is my message", 
            "kubernetes"  => {
              "namespace_name" => "appnamespace",
              "namespace_id" => "uuid-uuid-uuid-uuid"
            }
        }
    end

    def log
        return self
    end

    def error(args)
        @logs << args
    end

    def configure_ein(name_type, static_index_name: '', enable: true)
        ein = OpenStruct.new(
            name_type: name_type,
            tag: '**', 
            enabled: enable,
            static_index_name: static_index_name,
        )
        ein.define_singleton_method(:matcher) do
            @params[:matcher]
          end
        ein.instance_eval{@params = {}}
        @elasticsearch_index_names = [ein]
        configure_elasticsearch_index_names
    end

    sub_test_case '#elasticsearch_index_names' do

        sub_test_case 'when configuring enablement' do

            test 'should skip processing if disabled' do
                configure_ein(:operations_prefix, enable: false)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_nil(@rec['viaq_index_name'])
            end
        end

        sub_test_case 'should set the index name to the .orphaned namespace' do

            test 'when missing kubernetes field' do
                @rec.delete("kubernetes")
                configure_ein(:project_prefix)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_match(/record is missing kubernetes field/, @logs[0])
                assert_equal('.orphaned', @rec['viaq_index_name'])
            end
            test 'when missing kubernetes.namespace_name' do
                @rec["kubernetes"].delete('namespace_name')
                configure_ein(:project_prefix)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_match(/record is missing kubernetes.namespace_name field/, @logs[0])
                assert_equal('.orphaned', @rec['viaq_index_name'])
            end
            test 'when missing  kubernetes.namespace_id' do
                @rec["kubernetes"].delete('namespace_id')
                configure_ein(:project_prefix)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_match(/record is missing kubernetes.namespace_id field/, @logs[0])
                assert_equal('.orphaned', @rec['viaq_index_name'])
            end
        end

        sub_test_case 'when configured for name_type :static' do
            
            setup do
                @rec = {"message" => "20210909T12:15:09 Warning Some Warning message"}
                @elasticsearch_index_prefix_field = 'my_index_prefix'
            end
            
            test "should set the prefix field to the configured value" do
                configure_ein(:static, static_index_name: 'foo-bar')
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('foo-bar', @rec['my_index_prefix'])
            end
            
        end
        
        sub_test_case 'when configured for name_type :operations_prefix' do

            test "should set the prefix field to the configured value" do
                configure_ein(:operations_prefix)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('.operations', @rec['viaq_index_name'])
            end
        end
        sub_test_case 'when configured for name_type :operations_full' do
            
            test "should set the prefix field to the configured value" do
                configure_ein(:operations_full)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('.operations.2017.07.27', @rec['viaq_index_name'])
            end
        end
        
        sub_test_case 'when configured for name_type :project_prefix' do
            test "should set the prefix field to the configured value" do
                configure_ein(:project_prefix)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('project.appnamespace.uuid-uuid-uuid-uuid', @rec['viaq_index_name'])
            end
            test "should set the named prefix field to the configured value" do
                @elasticsearch_index_prefix_field = 'my_index_prefix'
                configure_ein(:project_prefix)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('project.appnamespace.uuid-uuid-uuid-uuid', @rec['my_index_prefix'])
            end
        end
        sub_test_case 'when configured for name_type :project_full' do
            test "should set the prefix field to the configured value" do
                configure_ein(:project_full)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('project.appnamespace.uuid-uuid-uuid-uuid.2017.07.27', @rec['viaq_index_name'])
            end
            test "should set the named prefix field to the configured value" do
                @elasticsearch_index_name_field = 'my_index_prefix'
                configure_ein(:project_full)
                add_elasticsearch_index_name_field('abc',nil, @rec)
                assert_equal('project.appnamespace.uuid-uuid-uuid-uuid.2017.07.27', @rec['my_index_prefix'])
            end
        end

    end

end