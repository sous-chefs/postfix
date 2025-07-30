# Author:: Joshua Timberman(<joshua@chef.io>)
# Cookbook:: common
# Recipe:: default
#
# Copyright:: 2009-2020, Chef Software, Inc.
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

include_recipe 'postfix::_attributes'

# use multi-package when we can
if node['os'] == 'linux'
  package node['postfix']['packages']
else
  node['postfix']['packages'].each do |pkg|
    package pkg
  end
end

package 'procmail' if node['postfix']['use_procmail']

case node['platform_family']
when 'rhel', 'fedora', 'amazon'
  service 'sendmail' do
    action :nothing
  end

  execute 'switch_mailer_to_postfix' do
    command '/usr/sbin/alternatives --set mta /usr/sbin/sendmail.postfix'
    notifies :stop, 'service[sendmail]'
    notifies :start, 'service[postfix]'
    not_if '/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix'
  end
when 'suse'
  file '/var/adm/postfix.configured'
when 'omnios'
  manifest_path = ::File.join(Chef::Config[:file_cache_path], 'manifest-postfix.xml')

  # we need to manage the postfix group and user
  # and then subscribe to the package install because it creates a
  # postdrop group and adds postfix user to it.
  group 'postfix' do
    append true
  end

  user 'postfix' do
    uid node['postfix']['uid']
    gid 'postfix'
    home '/var/spool/postfix'
    subscribes :manage, 'package[postfix]'
    notifies :run, 'execute[/opt/omni/sbin/postfix set-permissions]', :immediately
  end

  # we don't guard this because if the user creation was successful (or happened out of band), then this won't get executed when the action is :nothing.
  execute '/opt/omni/sbin/postfix set-permissions'

  template manifest_path do
    source 'manifest-postfix.xml.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    notifies :run, 'execute[load postfix manifest]', :immediately
  end

  execute 'load postfix manifest' do
    action :nothing
    command "svccfg import #{manifest_path}"
    notifies :restart, 'service[postfix]' unless platform_family?('solaris2')
  end
when 'freebsd'
  # Actions are based on docs provided by FreeBSD:
  # https://www.freebsd.org/doc/handbook/mail-changingmta.html
  service 'sendmail' do
    action :nothing
  end

  template '/etc/mail/mailer.conf' do
    source 'mailer.erb'
    owner 'root'
    group 0
    notifies :restart, 'service[postfix]' unless platform_family?('solaris2')
  end

  execute 'switch_mailer_to_postfix' do
    command [
      'sysrc',
      'sendmail_enable=NO',
      'sendmail_submit_enable=NO',
      'sendmail_outbound_enable=NO',
      'sendmail_msp_queue_enable=NO',
      'postfix_enable=YES',
    ]
    notifies :stop, 'service[sendmail]', :immediately
    notifies :disable, 'service[sendmail]', :immediately
    notifies :start, 'service[postfix]', :delayed
    only_if "sysrc sendmail_enable sendmail_submit_enable sendmail_outbound_enable sendmail_msp_queue_enable | egrep -q '(YES|unknown variable)' || sysrc postfix_enable | egrep -q '(NO|unknown variable)'"
  end

  execute 'disable_periodic' do
    # rubocop:disable Lint/ParenthesesAsGroupedExpression
    environment ({ 'RC_CONFS' => '/etc/periodic.conf' })
    command [
      'sysrc',
      'daily_clean_hoststat_enable=NO',
      'daily_status_mail_rejects_enable=NO',
      'daily_status_include_submit_mailq=NO',
      'daily_submit_queuerun=NO',
    ]
    only_if "RC_CONFS=/etc/periodic.conf sysrc daily_clean_hoststat_enable daily_status_mail_rejects_enable daily_status_include_submit_mailq daily_submit_queuerun | egrep -q '(YES|unknown variable)'"
  end
end

# We need to write the config first as the below postmap immediately commands assume config is correct
# Which is not the case as ipv6 is assumed to be available by the postfix package
# And if someone wants to disable this first we need to update the config first aswell
%w( main master ).each do |cfg|
  template "#{node['postfix']['conf_dir']}/#{cfg}.cf" do
    source "#{cfg}.cf.erb"
    owner 'root'
    group node['root_group']
    mode '0644'
    # restart service for solaris on chef-client has a bug
    # unless condition can be removed after
    # https://github.com/chef/chef/pull/6596 merge/release
    notifies :restart, 'service[postfix]' unless platform_family?('solaris2')
    variables(
      lazy { { settings: node['postfix'][cfg] } }
    )
    cookbook node['postfix']["#{cfg}_template_source"]
  end
end

execute 'update-postfix-sender_canonical' do
  command "postmap #{node['postfix']['conf_dir']}/sender_canonical"
  action :nothing
end

unless node['postfix']['sender_canonical_map_entries'].empty?
  template "#{node['postfix']['conf_dir']}/sender_canonical" do
    owner 'root'
    group node['root_group']
    mode '0644'
    notifies :run, 'execute[update-postfix-sender_canonical]', :immediately
    notifies :reload, 'service[postfix]'
  end

  node.default['postfix']['main']['sender_canonical_maps'] = "#{node['postfix']['db_type']}:#{node['postfix']['conf_dir']}/sender_canonical" unless node['postfix']['main'].key?('sender_canonical_maps')
end

execute 'update-postfix-smtp_generic' do
  command "postmap #{node['postfix']['conf_dir']}/smtp_generic"
  action :nothing
end

unless node['postfix']['smtp_generic_map_entries'].empty?
  template "#{node['postfix']['conf_dir']}/smtp_generic" do
    owner 'root'
    group node['root_group']
    mode '0644'
    notifies :run, 'execute[update-postfix-smtp_generic]', :immediately
    notifies :reload, 'service[postfix]'
  end

  node.default['postfix']['main']['smtp_generic_maps'] = "#{node['postfix']['db_type']}:#{node['postfix']['conf_dir']}/smtp_generic" unless node['postfix']['main'].key?('smtp_generic_maps')
end

execute 'update-postfix-recipient_canonical' do
  command "postmap #{node['postfix']['conf_dir']}/recipient_canonical"
  action :nothing
end

unless node['postfix']['recipient_canonical_map_entries'].empty?
  template "#{node['postfix']['conf_dir']}/recipient_canonical" do
    owner 'root'
    group node['root_group']
    mode '0644'
    notifies :run, 'execute[update-postfix-recipient_canonical]', :immediately
    notifies :reload, 'service[postfix]'
  end

  node.default['postfix']['main']['recipient_canonical_maps'] = "#{node['postfix']['db_type']}:#{node['postfix']['conf_dir']}/recipient_canonical" unless node['postfix']['main'].key?('recipient_canonical_maps')
end

service 'postfix' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
