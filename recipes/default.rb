# encoding: utf-8
# Author:: Joshua Timberman(<joshua@chef.io>)
# Cookbook Name:: postfix
# Recipe:: default
#
# Copyright 2009-2014, Chef Software, Inc.
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

if node['postfix']['main']['smtp_sasl_auth_enable'] == 'yes'
  include_recipe 'postfix::sasl_auth'
end

if node['postfix']['use_alias_maps']
  include_recipe 'postfix::aliases'
end

if node['postfix']['use_transport_maps']
  include_recipe 'postfix::transports'
end

if node['postfix']['use_access_maps']
  include_recipe 'postfix::access'
end

<<<<<<< HEAD
execute 'update-postfix-smtp_generic' do
  command "postmap #{node['postfix']['conf_dir']}/smtp_generic"
  action :nothing
end

if !node['postfix']['smtp_generic_map_entries'].empty?
  template "#{node['postfix']['conf_dir']}/smtp_generic" do
    owner 'root'
    group 0
    mode  '0644'
    notifies :run, 'execute[update-postfix-smtp_generic]'
    notifies :reload, 'service[postfix]'
  end

  if !node['postfix']['main'].key?('smtp_generic_maps')
    node.set['postfix']['main']['smtp_generic_maps'] = "hash:#{node['postfix']['conf_dir']}/smtp_generic"
  end
end


%w{main master}.each do |cfg|
  template "#{node['postfix']['conf_dir']}/#{cfg}.cf" do
    source "#{cfg}.cf.erb"
    owner 'root'
    group 0
    mode 00644
    notifies :restart, 'service[postfix]'
    variables(settings: node['postfix'][cfg])
    cookbook node['postfix']["#{cfg}_template_source"]
  end
=======
if node['postfix']['use_virtual_aliases']
  include_recipe 'postfix::virtual_aliases'
>>>>>>> upstream/master
end

if node['postfix']['use_virtual_aliases_domains']
  include_recipe 'postfix::virtual_aliases_domains'
end
