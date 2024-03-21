#
# Cookbook:: passenger
# Recipe:: apache
#
# Copyright:: 2024, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apache"
include_recipe "passenger"

apache_module "passenger" do
  conf "apache.conf.erb"
end

notify_group "passenger-reload-apache" do
  subscribes :run, "template[/usr/local/bin/passenger-ruby]"
  notifies :reload, "service[apache2]"
end
