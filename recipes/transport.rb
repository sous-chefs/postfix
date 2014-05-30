# encoding: utf-8
#
# Cookbook Name:: postfix
# Recipe:: transport
#
# Copyright 2009, Opscode, Inc.
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

include_recipe 'postfix'

execute 'postmap-transport' do
  command "postmap #{node['postfix']['transport']['file']}"
  action :nothing
end

template node['postfix']['transport']['file'] do
  source 'transport.erb'
  owner 'root'
  group 0
  mode 00644
  notifies :run, 'execute[postmap-transport]', :immediately
  notifies :restart, 'service[postfix]'
  variables(settings: node['postfix']['transport']['entries'])
end
