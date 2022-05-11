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

    module FlattenLabels

        # flatten_labels makes kubernetes.labels into a key=value array
        # and adds the result to the key 'flat_labels' key removing all
        # but the exclusions from the original set
        def flatten_labels(record, exclusions = [])
            return record if record.nil? || record.dig('kubernetes','labels').nil?
            kube = record['kubernetes']
            kube['flat_labels'] = kube['labels'].map do |k,v| 
                "#{k}=#{v}" unless exclusions.include?(k)
            end.compact
            kube['labels'].delete_if do |k,v|
                !exclusions.include?(k)
            end
            kube.delete('labels') if kube['labels'].empty?
            record
        end

    end
end