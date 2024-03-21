#
# Cookbook:: nginx
# Resource:: nginx_module
#
# Copyright:: 2024, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unified_mode true

property :module, :kind_of => String, :name_property => true
property :package, :kind_of => String
property :conf, :kind_of => String
property :variables, :kind_of => Hash, :default => {}
property :restart_nginx, :kind_of => [TrueClass, FalseClass], :default => true

action :install do
  declare_resource :package, package_name

  if new_resource.conf
    template conf_name do
      source new_resource.conf
      owner "root"
      group "root"
      mode "644"
      variables new_resource.variables
    end
  end
end

action :delete do
  if new_resource.conf
    file conf_name do
      action :delete
    end
  end

  package package_name do
    action :remove
  end
end

action_class do
  def package_name
    new_resource.package || "libnginx-mod-#{new_resource.module}"
  end

  def conf_name
    "/etc/nginx/conf.d/mod-{new_resource.module}.conf"
  end
end

def after_created
  notifies :restart, "service[nginx]" if restart_nginx
end
