# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: install
#

provides :postfix_install
unified_mode true
use '_partial/_common'

property :packages, Array, desired_state: false
property :use_procmail, [true, false], desired_state: false

action_class do
  include PostfixCookbook::Helpers
end

action :install do
  package_names = new_resource.packages || postfix_packages
  procmail = new_resource.use_procmail.nil? ? postfix_setting('use_procmail', false) : new_resource.use_procmail

  if node['os'] == 'linux'
    package package_names
  else
    package_names.each do |pkg|
      package pkg
    end
  end

  package 'procmail' if procmail

  service new_resource.service_name do
    action :nothing
  end

  case node['platform_family']
  when 'rhel', 'fedora', 'amazon'
    service 'sendmail' do
      action :nothing
    end

    execute 'switch_mailer_to_postfix' do
      command '/usr/sbin/alternatives --set mta /usr/sbin/sendmail.postfix'
      notifies :stop, 'service[sendmail]'
      notifies :start, "service[#{new_resource.service_name}]"
      not_if '/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix'
    end
  when 'suse'
    file '/var/adm/postfix.configured'
  when 'freebsd'
    service 'sendmail' do
      action :nothing
    end

    template '/etc/mail/mailer.conf' do
      source 'mailer.erb'
      owner 'root'
      group 0
      cookbook 'postfix'
      notifies :restart, "service[#{new_resource.service_name}]"
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
      notifies :start, "service[#{new_resource.service_name}]", :delayed
      only_if "sysrc sendmail_enable sendmail_submit_enable sendmail_outbound_enable sendmail_msp_queue_enable | egrep -q '(YES|unknown variable)' || sysrc postfix_enable | egrep -q '(NO|unknown variable)'"
    end

    execute 'disable_periodic' do
      environment({ 'RC_CONFS' => '/etc/periodic.conf' })
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
end
