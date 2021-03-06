#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'fluent/plugin/formatter'
require 'json'

module Fluent
  module Plugin
    class SingleJsonValueFormatter < Formatter
      Plugin.register_formatter('single_json_value', self)

      config_param :message_key, :string, default: 'message'
      config_param :add_newline, :bool, default: true

      def format(tag, time, record)
        m = record[@message_key]
        if m.is_a?(Hash)
          text = m.to_json.dup
        else
          text = m.to_s.dup
        end
        text << "\n" if @add_newline
        text
      end
    end
  end
end
