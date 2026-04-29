# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: _partial/_common
#

property :conf_dir, String, desired_state: false
property :db_type, String, desired_state: false
property :service_name, String, default: 'postfix', desired_state: false
property :owner, String, default: 'root', desired_state: false
property :group, String, desired_state: false
