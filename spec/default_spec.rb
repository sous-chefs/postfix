require 'spec_helper'

describe 'postfix::default' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix').and_return(true)
  end

  context 'on Centos 8' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '8').converge(described_recipe)
    end

    it '[COOK-4423] renders file main.cf with /etc/pki/tls/cert.pem' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{smtp_tls_CAfile += +/etc/pki/tls/cert.pem})
    end

    it '[COOK-4619] does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end

  context 'on Ubuntu 20.04' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: 20.04).converge(described_recipe)
    end

    it '[COOK-4423] renders file main.cf with /etc/postfix/cacert.pem' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{smtp_tls_CAfile += +/etc/ssl/certs/ca-certificates.crt})
    end

    it '[COOK-4619] does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end
end
