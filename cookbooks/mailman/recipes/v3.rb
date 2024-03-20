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
include_recipe "podman"
include_recipe "postgresql"

postgresql_user "www-data" do
  cluster "15/main"
end

postgresql_database "mailman" do
  cluster "15/main"
  owner "www-data"
end

directory "/srv/lists/openstreetmap.org" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/srv/lists/openstreetmap.org/core" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/srv/lists/openstreetmap.org/web" do
  owner "root"
  group "root"
  mode "0755"
end

hyperkitty_api_key = persistent_token("mailman", "hyperkitty_api_key")

podman_service "mailman-core" do
  description ""
  image "maxking/mailman-core:0.4"
  ports 8001 => 8001,
        8024 => 8024
  volumes "/run/postgresql" => "/run/postgresql",
          "/srv/lists.openstreetmap.org/core" => "/opt/mailman"
  environment "HYPERKITTY_API_KEY" => hyperkitty_api_key,
              "DATABASE_URL" => "postgresql:///mailman?host=/run/postgesql",
              "DATABASE_TYPE" => "postgres",
              "DATABASE_CLASS" => "mailman.database.postgresql.PostgreSQLDatabase"
end

podman_service "mailman-web" do
  description ""
  image "maxking/mailman-web:0.4"
  ports 8000 => 8000,
        8080 => 8080
  volumes "/run/postgresql" => "/run/postgresql",
          "/srv/lists.openstreetmap.org/web" => "/opt/mailman-web-data"
  environment "DATABASE_URL" => "postgresql:///mailman?host=/run/postgesql",
              "DATABASE_TYPE" => "postgres",
              "HYPERKITTY_API_KEY" => hyperkitty_api_key
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
