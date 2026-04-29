# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: client
#

provides :postfix_client
unified_mode true
use '_partial/_common'

property :relayhost_role, String, desired_state: false
property :relayhost_port, [String, Integer], desired_state: false
property :multi_environment_relay, [true, false], desired_state: false

action_class do
  include PostfixCookbook::Helpers
end

action :create do
  if Chef::Config[:solo]
    Chef::Log.info('postfix_client is intended for use with Chef Server; use postfix instead with Chef Solo.')
    next
  end

  role = new_resource.relayhost_role || postfix_setting('relayhost_role', 'relayhost')
  port = (new_resource.relayhost_port || postfix_setting('relayhost_port', '25')).to_s
  multi_environment = new_resource.multi_environment_relay.nil? ? postfix_setting('multi_environment_relay', false) : new_resource.multi_environment_relay
  query = "role:#{role}"

  relayhost = if node.run_list.roles.include?(role)
                node['ipaddress']
              elsif multi_environment
                search(:node, query).map { |n| n['ipaddress'] }.first
              else
                search(:node, "#{query} AND chef_environment:#{node.chef_environment}").map { |n| n['ipaddress'] }.first
              end

  relayhost_port = port == '25' ? '' : ":#{port}"

  postfix new_resource.name do
    main_settings('relayhost' => "[#{relayhost}]#{relayhost_port}")
  end
end
