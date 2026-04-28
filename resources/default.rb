# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: default
#

provides :postfix
unified_mode true
use '_partial/_common'

property :mail_type, String, desired_state: false
property :main_settings, Hash, desired_state: false
property :master_settings, Hash, desired_state: false
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
property :sasl, Hash, desired_state: false

action_class do
  include PostfixCookbook::Helpers

  def resource_flag(name, default)
    value = new_resource.send(name)
    value.nil? ? postfix_setting(name.to_s, default) : value
  end
end

action :create do
  use_procmail = resource_flag(:use_procmail, false)
  main_settings = postfix_default_main_settings(
    _conf_dir: new_resource.conf_dir || postfix_path(:conf_dir),
    db_type: new_resource.db_type || postfix_db_type
  )
  main_settings.merge!(new_resource.main_settings) if new_resource.main_settings

  postfix_install new_resource.name do
    conf_dir new_resource.conf_dir if new_resource.conf_dir
    db_type new_resource.db_type if new_resource.db_type
    service_name new_resource.service_name
    use_procmail use_procmail
  end

  postfix_config new_resource.name do
    conf_dir new_resource.conf_dir if new_resource.conf_dir
    db_type new_resource.db_type if new_resource.db_type
    service_name new_resource.service_name
    mail_type new_resource.mail_type if new_resource.mail_type
    main_settings main_settings
    master_settings new_resource.master_settings if new_resource.master_settings
    use_procmail use_procmail
    use_alias_maps resource_flag(:use_alias_maps, platform?('freebsd'))
    use_transport_maps resource_flag(:use_transport_maps, false)
    use_access_maps resource_flag(:use_access_maps, false)
    use_virtual_aliases resource_flag(:use_virtual_aliases, false)
    use_virtual_aliases_domains resource_flag(:use_virtual_aliases_domains, false)
    use_relay_restrictions_maps resource_flag(:use_relay_restrictions_maps, false)
    aliases new_resource.aliases if new_resource.aliases
    transports new_resource.transports if new_resource.transports
    access new_resource.access if new_resource.access
    virtual_aliases new_resource.virtual_aliases if new_resource.virtual_aliases
    virtual_aliases_domains new_resource.virtual_aliases_domains if new_resource.virtual_aliases_domains
    relay_restrictions new_resource.relay_restrictions if new_resource.relay_restrictions
    maps new_resource.maps if new_resource.maps
    sender_canonical_map_entries new_resource.sender_canonical_map_entries if new_resource.sender_canonical_map_entries
    smtp_generic_map_entries new_resource.smtp_generic_map_entries if new_resource.smtp_generic_map_entries
    recipient_canonical_map_entries new_resource.recipient_canonical_map_entries if new_resource.recipient_canonical_map_entries
  end

  postfix_sasl_auth new_resource.name do
    conf_dir new_resource.conf_dir if new_resource.conf_dir
    db_type new_resource.db_type if new_resource.db_type
    service_name new_resource.service_name
    sasl new_resource.sasl if new_resource.sasl
  end if main_settings['smtp_sasl_auth_enable'] == 'yes'

  postfix_service new_resource.service_name
end
