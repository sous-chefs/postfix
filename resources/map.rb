# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: map
#

provides :postfix_map
unified_mode true
use '_partial/_common'

property :path, String, name_property: true
property :type, String, default: 'hash', desired_state: false
property :content, Hash, default: {}, desired_state: false
property :template_source, String, default: 'maps.erb', desired_state: false
property :separator, String, desired_state: false
property :sensitive, [true, false], default: false, desired_state: false
property :mode, String, default: '0644', desired_state: false
property :postmap, [true, false], default: true, desired_state: false
property :update_command, String, desired_state: false
property :reload_service, [true, false], default: false, desired_state: false
property :restart_service, [true, false], default: false, desired_state: false

action_class do
  include PostfixCookbook::Helpers
end

action :create do
  map_separator = new_resource.separator || postfix_map_separator(new_resource.type)
  command = new_resource.update_command || "#{postfix_postmap_command} #{new_resource.path}"

  service new_resource.service_name do
    action :nothing
  end

  execute "update-postfix-map-#{new_resource.path}" do
    command command
    environment postfix_path_environment if platform_family?('omnios')
    action :nothing
  end if new_resource.postmap

  template new_resource.path do
    source new_resource.template_source
    owner new_resource.owner
    group new_resource.group || node['root_group']
    mode new_resource.mode
    sensitive new_resource.sensitive
    cookbook 'postfix'
    variables(
      map: new_resource.content,
      settings: new_resource.content,
      separator: map_separator
    )
    notifies :run, "execute[update-postfix-map-#{new_resource.path}]", :immediately if new_resource.postmap
    notifies :reload, "service[#{new_resource.service_name}]" if new_resource.reload_service
    notifies :restart, "service[#{new_resource.service_name}]" if new_resource.restart_service
  end
end
