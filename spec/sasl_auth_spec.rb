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

    it 'creates the password file directory before writing the file' do
      names = chef_run.resource_collection.all_resources.map(&:to_s)
      expect(chef_run).to create_directory('/etc/postfix')
      expect(names.index('directory[/etc/postfix]')).to be < names.index("template[#{password_file}]")
    end

    it 'builds the map with the platform database type' do
      expect(chef_run.execute("update-postfix-map-#{password_file}").command).to eq("postmap hash:#{password_file}")
    end
  end
end
