# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: config
#

provides :postfix_config
unified_mode true
use '_partial/_common'

property :mail_type, String, desired_state: false
property :main_settings, Hash, desired_state: false
property :master_settings, Hash, desired_state: false
property :main_template_cookbook, String, desired_state: false
property :master_template_cookbook, String, desired_state: false
property :use_procmail, [true, false], desired_state: false
property :use_alias_maps, [true, false], desired_state: false
property :use_transport_maps, [true, false], desired_state: false
property :use_access_maps, [true, false], desired_state: false
property :use_virtual_aliases, [true, false], desired_state: false
property :use_virtual_aliases_domains, [true, false], desired_state: false
property :use_relay_restrictions_maps, [true, false], desired_state: false
property :aliases, Hash, desired_state: false
property :transports, Hash, desired_state: false
property :access, Hash, desired_state: false
property :virtual_aliases, Hash, desired_state: false
property :virtual_aliases_domains, Hash, desired_state: false
property :relay_restrictions, Hash, desired_state: false
property :maps, Hash, desired_state: false
property :sender_canonical_map_entries, Hash, desired_state: false
property :smtp_generic_map_entries, Hash, desired_state: false
property :recipient_canonical_map_entries, Hash, desired_state: false

action_class do
  include PostfixCookbook::Helpers

  def resource_flag(name, default)
    value = new_resource.send(name)
    value.nil? ? postfix_setting(name.to_s, default) : value
  end
end

action :create do
  conf_dir = new_resource.conf_dir || postfix_path(:conf_dir)
  db_type = new_resource.db_type || postfix_db_type
  mail_type = new_resource.mail_type || postfix_setting('mail_type', 'client')
  use_procmail = resource_flag(:use_procmail, false)
  use_alias_maps = resource_flag(:use_alias_maps, platform?('freebsd'))
  use_transport_maps = resource_flag(:use_transport_maps, false)
  use_access_maps = resource_flag(:use_access_maps, false)
  use_virtual_aliases = resource_flag(:use_virtual_aliases, false)
  use_virtual_aliases_domains = resource_flag(:use_virtual_aliases_domains, false)
  use_relay_restrictions_maps = resource_flag(:use_relay_restrictions_maps, false)

  main_settings = postfix_default_main_settings(_conf_dir: conf_dir, db_type: db_type)
  main_settings.merge!(new_resource.main_settings) if new_resource.main_settings
  main_settings = postfix_derived_main_settings(
    main_settings,
    conf_dir: conf_dir,
    db_type: db_type,
    use_procmail: use_procmail,
    use_alias_maps: use_alias_maps,
    use_transport_maps: use_transport_maps,
    use_virtual_aliases: use_virtual_aliases,
    use_virtual_aliases_domains: use_virtual_aliases_domains,
    use_relay_restrictions_maps: use_relay_restrictions_maps
  )
  canonical_maps = {
    'sender_canonical' => new_resource.sender_canonical_map_entries || postfix_setting('sender_canonical_map_entries', {}),
    'smtp_generic' => new_resource.smtp_generic_map_entries || postfix_setting('smtp_generic_map_entries', {}),
    'recipient_canonical' => new_resource.recipient_canonical_map_entries || postfix_setting('recipient_canonical_map_entries', {}),
  }
  canonical_maps.each do |map_name, content|
    next if content.nil? || content.empty?

    main_settings["#{map_name}_maps"] ||= "#{db_type}:#{conf_dir}/#{map_name}"
  end

  master_settings = postfix_default_master_settings.merge(postfix_setting('master', {}).to_h)
  master_settings.merge!(new_resource.master_settings) if new_resource.master_settings

  service new_resource.service_name do
    action :nothing
  end

  directory conf_dir do
    owner new_resource.owner
    group new_resource.group || node['root_group']
    mode '0755'
  end

  template "#{conf_dir}/main.cf" do
    source 'main.cf.erb'
    owner new_resource.owner
    group new_resource.group || node['root_group']
    mode '0644'
    cookbook new_resource.main_template_cookbook || postfix_setting('main_template_source', 'postfix')
    variables(settings: main_settings, mail_type: mail_type)
    notifies :restart, "service[#{new_resource.service_name}]"
  end

  template "#{conf_dir}/master.cf" do
    source 'master.cf.erb'
    owner new_resource.owner
    group new_resource.group || node['root_group']
    mode '0644'
    cookbook new_resource.master_template_cookbook || postfix_setting('master_template_source', 'postfix')
    variables(settings: master_settings)
    notifies :restart, "service[#{new_resource.service_name}]"
  end

  postfix_map postfix_path(:aliases_db) do
    content(new_resource.aliases || postfix_aliases)
    template_source 'aliases.erb'
    postmap false
    update_command 'newaliases'
  end if use_alias_maps

  postfix_map postfix_path(:transport_db) do
    content(new_resource.transports || postfix_setting('transports', {}))
    template_source 'maps.erb'
    type db_type
  end if use_transport_maps

  postfix_map postfix_path(:access_db) do
    content(new_resource.access || postfix_setting('access', {}))
    template_source 'maps.erb'
    type db_type
  end if use_access_maps

  postfix_map postfix_path(:virtual_alias_db) do
    content(new_resource.virtual_aliases || postfix_setting('virtual_aliases', {}))
    template_source 'maps.erb'
    type(postfix_setting('virtual_alias_db_type') || db_type)
    restart_service true
  end if use_virtual_aliases

  postfix_map postfix_path(:virtual_alias_domains_db) do
    content(new_resource.virtual_aliases_domains || postfix_setting('virtual_aliases_domains', {}))
    template_source 'maps.erb'
    type(postfix_setting('virtual_alias_domains_db_type') || db_type)
    restart_service true
  end if use_virtual_aliases_domains

  postfix_map postfix_path(:relay_restrictions_db) do
    content(new_resource.relay_restrictions || postfix_setting('relay_restrictions', {}))
    template_source 'maps.erb'
    type db_type
  end if use_relay_restrictions_maps

  canonical_maps.each do |map_name, content|
    next if content.nil? || content.empty?

    postfix_map "#{conf_dir}/#{map_name}" do
      content content
      type db_type
      reload_service true
    end
  end

  (new_resource.maps || postfix_setting('maps', {})).each do |type, map_files|
    if platform_family?('debian') && %w(pgsql mysql ldap cdb).include?(type)
      package "postfix-#{type}"
    end

    if platform_family?('rhel') && node['platform_version'].to_i >= 8 && PostfixCookbook::Helpers::PACKAGE_MAP_TYPES.include?(type)
      package "postfix-#{type}"
    end

    map_files.each do |path, content|
      postfix_map path do
        content content
        type type
        postmap PostfixCookbook::Helpers::POSTMAP_DATABASE_TYPES.include?(type)
        restart_service true
        only_if "postconf -m | grep -q #{type}"
      end
    end
  end
end
