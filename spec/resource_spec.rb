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

  context 'postfix_install with exim4 present' do
    let(:chef_run) do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/usr/sbin/exim4').and_return(true)
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_install')
    end

    it 'stops and purges exim4 so postfix can bind port 25' do
      expect(chef_run).to stop_service('exim4')
      expect(chef_run).to disable_service('exim4')
      expect(chef_run).to purge_package('exim4')
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

  context 'postfix_config with access maps' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_config_access')
    end

    it 'renders the access map file' do
      expect(chef_run).to render_file('/etc/postfix/access').with_content(/^example.com OK$/)
    end

    it 'does not emit a bogus access_maps parameter in main.cf' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content(/access_maps/)
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
