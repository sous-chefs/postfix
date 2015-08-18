#
# Cookbook Name:: postfix
# Resource:: sasldb_user
#

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class PostfixSasldbUser < Chef::Resource::LWRPBase
      resource_name :postfix_sasldb_user

      attr_reader :username, :domain
      attr_writer :exists

      attribute :email, kind_of: String, name_attribute: true, regex: /\A[^@]+@[^@]+\Z/
      attribute :password, kind_of: String

      actions :create, :disable
      default_action :create

      def initialize(name, run_context = nil)
        super

        @username, @domain = email.split('@')
        @exists = false
      end

      def exists?
        @exists
      end
    end
  end
end
