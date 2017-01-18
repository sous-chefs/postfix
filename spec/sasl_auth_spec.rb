require 'spec_helper'

describe 'postfix::sasl_auth' do
  let(:password_file) { '/etc/postfix/sasl_passwd' }

  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: 16.04) do |node|
      node.default['postfix']['sasl_password_file'] = password_file
    end.converge(described_recipe)
  end

  describe 'password file template' do
    it 'does not display sensitive information' do
      expect(chef_run).to create_template(password_file).with(sensitive: true)
    end
  end
end
