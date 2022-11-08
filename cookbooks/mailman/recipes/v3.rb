#
# Cookbook:: mailman
# Recipe:: v3
#
# Copyright:: 2022, OpenStreetMap Foundation
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
include_recipe "postgresql"

postgresql_user "www-data" do
  cluster "15/main"
end

postgresql_database "mailman" do
  cluster "15/main"
  owner "www-data"
end

directory "/etc/mailman3" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/mailman3/mailman-web.py" do
  source "mailman-web.py.erb"
  owner "root"
  group "www-data"
  mode "0640"
end

package "mailman3-web"

service "mailman3-web" do
  action [:enable, :start]
end

apache_module "proxy_uwsgi" do
  package "libapache2-mod-proxy-uwsgi"
end

ssl_certificate "lists.openstreetmap.org" do
  domains ["lists.openstreetmap.org", "lists.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "lists.openstreetmap.org" do
  template "apache.v3.erb"
  directory "/srv/lists.openstreetmap.org"
  variables :aliases => ["lists.osm.org"]
end
