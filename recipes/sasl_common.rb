# Author:: Joshua Timberman(<joshua@chef.io>)
# Cookbook Name:: postfix
# Recipe:: sasl_common
#
# Copyright 2009-2018, Chef Software, Inc.
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

sasl_pkgs = []

# We use case instead of value_for_platform_family because we need
# version specifics for RHEL.
case node['platform_family']
when 'debian'
  sasl_pkgs = %w(libsasl2-2 libsasl2-modules ca-certificates sasl2-bin)
when 'rhel'
  sasl_pkgs = if node['platform_version'].to_i < 6
                %w(cyrus-sasl cyrus-sasl-plain openssl)
              else
                %w(cyrus-sasl cyrus-sasl-plain ca-certificates)
              end
when 'amazon', 'fedora'
  sasl_pkgs = %w(cyrus-sasl cyrus-sasl-plain ca-certificates)
end

sasl_pkgs.each do |pkg|
  package pkg
end

default_cyrus_sasl = "/etc/sasl#{2 unless platform_family? 'omnios', 'smartos'}"
cyrus_sasl = node['postfix']['main']['cyrus_sasl_config_path'] || default_cyrus_sasl
smtpd = node['postfix']['main']['smtpd_sasl_path'] || 'smtpd'

directory cyrus_sasl do
  owner 'root'
  group node['root_group']
  mode '0755'
end

template "#{cyrus_sasl}/#{smtpd}.conf" do
  source 'sasl.conf.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  variables(settings: node['postfix']['sasl_conf'])
end
