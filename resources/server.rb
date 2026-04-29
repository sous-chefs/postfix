# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: server
#

provides :postfix_server
unified_mode true
use '_partial/_common'

action :create do
  postfix new_resource.name do
    mail_type 'master'
    main_settings('inet_interfaces' => 'all')
  end
end
