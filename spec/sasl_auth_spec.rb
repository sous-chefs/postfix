require 'spec_helper'

describe 'postfix_sasl_auth resource' do
  let(:password_file) { '/etc/postfix/sasl_passwd' }

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_sasl_auth')
  end

  describe 'password file template' do
    it 'does not display sensitive information' do
      expect(chef_run).to create_template(password_file).with(sensitive: true)
    end
  end
end
