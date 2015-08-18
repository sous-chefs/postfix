#
# Author:: Joshua Timberman(<joshua@chef.io>)
# Cookbook:: postfix
# Recipe:: sasl_auth
#
# Copyright:: 2009-2018, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'postfix::_common'
include_recipe 'postfix::sasl_common'

execute 'postmap-sasl_passwd' do
  command "postmap #{node['postfix']['sasl_password_file']}"
  environment 'PATH' => "#{ENV['PATH']}:/opt/omni/bin:/opt/omni/sbin" if platform_family?('omnios')
  action :nothing
end

template node['postfix']['sasl_password_file'] do
  sensitive true
  source 'sasl_passwd.erb'
  owner 'root'
  group node['root_group']
  mode '400'
  notifies :run, 'execute[postmap-sasl_passwd]', :immediately
  notifies :restart, 'service[postfix]'
  variables(settings: node['postfix']['sasl'])
end
