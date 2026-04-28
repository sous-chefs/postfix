# frozen_string_literal: true

#
# Cookbook:: postfix
# Resource:: service
#

provides :postfix_service
unified_mode true
use '_partial/_common'

default_action %i(enable start)

action :enable do
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action :enable
  end
end

action :start do
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action :start
  end
end

action :restart do
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action :restart
  end
end

action :reload do
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action :reload
  end
end

action :stop do
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action :stop
  end
end

action :disable do
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action :disable
  end
end
