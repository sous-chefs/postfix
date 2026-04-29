require 'spec_helper'

describe 'postfix resource' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix').and_return(true)
  end

  context 'on AlmaLinux 9' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'almalinux', version: '9', step_into: postfix_step_into) do |node|
        node.normal['postfix']['main']['smtp_sasl_auth_enable'] = 'no'
      end

      runner.converge('test::spec_default')
    end

    it 'renders file main.cf with /etc/pki/tls/cert.pem' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{smtp_tls_CAfile += +/etc/pki/tls/cert.pem})
    end

    it 'does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end

  context 'on Ubuntu 24.04' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_default')
    end

    it 'renders file main.cf with /etc/ssl/certs/ca-certificates.crt' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{smtp_tls_CAfile += +/etc/ssl/certs/ca-certificates.crt})
    end

    it 'does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end
end
