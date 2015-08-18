#
# Cookbook Name:: postfix
# Provider:: sasldb_user
#

require 'chef/provider/lwrp_base'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class PostfixSasldbUser < Chef::Provider::LWRPBase
      include Chef::Mixin::ShellOut

      provides :postfix_sasldb_user
      use_inline_resources

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::PostfixSasldbUser.new(@new_resource.name)

        cmd = Mixlib::ShellOut.new("sasldblistusers2 | grep '^#{@current_resource.email}: '")
        cmd.run_command

        @current_resource.exists = true unless cmd.error?
        @current_resource
      end

      action :create do
        return if current_resource.exists?

        converge_by 'saslpasswd2 -c' do
          shell_out!('saslpasswd2', '-c', '-p', '-u', new_resource.domain, new_resource.username, input: new_resource.password)
        end

        set_permissions
      end

      action :disable do
        return unless current_resource.exists?

        converge_by 'saslpasswd2 -d' do
          shell_out!('saslpasswd2', '-d', '-u', current_resource.domain, current_resource.username)
        end

        set_permissions
      end

      def set_permissions
        file "sasldb permissions for #{@new_resource.name}" do
          path node['postfix']['sasldb']['path']
          owner 'root'
          group node['postfix']['sasldb']['group']
          mode '0640'
          action :touch
          only_if { ::File.exist? path }
        end
      end
    end
  end
end
