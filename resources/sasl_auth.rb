# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: sasl_auth
#

provides :postfix_sasl_auth
unified_mode true
use '_partial/_common'

property :sasl, Hash, desired_state: false
property :password_file, String, desired_state: false
property :packages, Array, desired_state: false

action_class do
  include PostfixCookbook::Helpers
end

action :create do
  conf_dir = new_resource.conf_dir || postfix_path(:conf_dir)
  package_names = new_resource.packages || postfix_sasl_packages
  password_file = new_resource.password_file || postfix_sasl_password_file(conf_dir)

  package_names.each do |pkg|
    package pkg
  end

  postfix_map password_file do
    content(new_resource.sasl || postfix_setting('sasl', {}))
    template_source 'sasl_passwd.erb'
    sensitive true
    mode '0400'
    update_command "postmap #{password_file}"
    restart_service true
  end
end
