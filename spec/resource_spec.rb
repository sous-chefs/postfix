require 'spec_helper'

describe 'postfix resources' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix').and_return(true)
  end

  context 'postfix_install' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_install')
    end

    it 'installs postfix' do
      expect(chef_run).to install_package(%w(postfix))
    end
  end

  context 'postfix_config with aliases' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_config_aliases')
    end

    it 'renders aliases through postfix_map' do
      expect(chef_run).to render_file('/etc/aliases').with_content(/^root: admin$/)
    end
  end

  context 'postfix_map' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_map')
    end

    it 'renders a map file' do
      expect(chef_run).to render_file('/etc/postfix/access').with_content(/^example.com OK$/)
    end
  end

  context 'postfix_server' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_server')
    end

    it 'renders server mode' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(/^inet_interfaces = all$/)
    end
  end
end
