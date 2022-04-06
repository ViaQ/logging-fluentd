#
# Fluentd ViaQ data model Filter Plugin
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
module ViaqDataModel
    module ElasticsearchIndexName

        def configure_elasticsearch_index_names
            unless @elasticsearch_index_names.empty?
                @elasticsearch_index_names.each do |ein|
                    if ein.name_type == :static && ein.static_index_name.empty?
                    raise Fluent::ConfigError, "'static' elasticsearch_index_name configurations must define 'static_index_name'"
                    end
                    matcher = ViaqMatchClass.new(ein.tag, nil)
                    ein.instance_eval{ @params[:matcher] = matcher }

                    unless ein.structured_type_key.nil?
                      ein.instance_eval{ @params[:structured_type_key] = ein.structured_type_key.split('.') }
                    end

                    unless ein.structured_type_annotation_prefix.nil?
                      if ein.structured_type_annotation_prefix[ein.structured_type_annotation_prefix.length - 1] == '/'
                        ein.instance_eval{ @params[:structured_type_annotation_prefix] = ein.structured_type_annotation_prefix[0,ein.structured_type_annotation_prefix.length - 1] }
                      end
                    end
                end
            end
        end

        # add_elasticsearch_index_name_field formats the index name to use when submitting the records
        # based on upon the type configured
        def add_elasticsearch_index_name_field(tag, time, record)
            found = false
            @elasticsearch_index_names.each do |ein|
              if ein.matcher.match(tag)
                found = true
                return unless ein.enabled
                if ein.name_type == :operations_full || ein.name_type == :project_full || ein.name_type == :audit_full
                  field_name = @elasticsearch_index_name_field
                  need_time = true
                else
                  field_name = @elasticsearch_index_prefix_field
                  need_time = false
                end
      
                case ein.name_type
                when :static
                  prefix = evaluate_for_static_name_type(ein)
                when :structured
                  prefix = evaluate_for_structured_name_type(ein, record)
                when :audit_full, :audit_prefix
                  prefix = ".audit"
                when :operations_full, :operations_prefix
                  prefix = ".operations"
                when :project_full, :project_prefix
                  name, uuid = nil
                  unless record['kubernetes'].nil?
                    k8s = record['kubernetes']
                    name = k8s['namespace_name']
                    uuid = k8s['namespace_id']
                    if name.nil?
                      log.error("record cannot use elasticsearch index name type #{ein.name_type}: record is missing kubernetes.namespace_name field: #{record}")
                    end
                    if uuid.nil?
                      log.error("record cannot use elasticsearch index name type #{ein.name_type}: record is missing kubernetes.namespace_id field: #{record}")
                    end
                  else
                    log.error("record cannot use elasticsearch index name type #{ein.name_type}: record is missing kubernetes field: #{record}")
                  end
                  if name.nil? || uuid.nil?
                    name = @orphaned_namespace_name
                  end
                  prefix = name == @orphaned_namespace_name ? @orphaned_namespace_name : "project.#{name}.#{uuid}"
                end
                if need_time
                  ts = DateTime.parse(record[@dest_time_name])
                  record[field_name] = prefix + "." + ts.strftime("%Y.%m.%d")
                else
                  record[field_name] = prefix
                end
                break
              end
            end
        end

        def evaluate_for_static_name_type(ein)
          ein.static_index_name
        end

        def evaluate_for_structured_name_type(ein, record)
          if !record['structured'].nil? && record['structured'] != {} 
            if !(type_from_annotation = evaluate_for_container_type_annotation(ein, record)).nil?
              "app-#{type_from_annotation}-write"
            elsif !ein.structured_type_key.nil? && !(type_from_key = record.dig(*ein.structured_type_key)).nil? 
              "app-#{type_from_key}-write"
            elsif !ein.structured_type_name.nil? && !ein.structured_type_name.empty?
              "app-#{ein.structured_type_name}-write"
            else 
              evaluate_for_static_name_type(ein)
            end
          else 
            evaluate_for_static_name_type(ein)
          end
        end

        def evaluate_for_container_type_annotation(ein, record)
          return nil if ein.structured_type_annotation_prefix.nil?
          unless (annotations = record.dig("kubernetes","annotations")).nil? || (container_name = record.dig("kubernetes","container_name")).nil?
            return nil if container_name.empty?
            pattern = "#{ein.structured_type_annotation_prefix}/#{container_name}"
            annotations.each do |k,v|
              return v if k == pattern
            end
          end
          nil
        end
    end
end