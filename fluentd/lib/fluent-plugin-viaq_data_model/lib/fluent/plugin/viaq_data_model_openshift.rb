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

    module OpenShift

        MAX_SEQUENCE = 2**32 - 1

        # add_openshift_data adds the data for the openshift block of the viaq data model
        def add_openshift_data(record)
            record['openshift'] = {} if record['openshift'].nil?
            if record['openshift']['sequence'].nil?
                record['openshift']['sequence'] = @openshift_sequence
                @openshift_sequence += 1
                @openshift_sequence = 1 if @openshift_sequence > MAX_SEQUENCE
            end
        end

    end
end