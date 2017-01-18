require 'spec_helper'

describe 'postfix::default' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix').and_return(true)
  end

  context 'on Centos 6' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'centos', version: 6.7).converge(described_recipe)
    end

    it '[COOK-4423] renders file main.cf with /etc/pki/tls/cert.pem' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{smtp_tls_CAfile += +/etc/pki/tls/cert.pem})
    end

    it '[COOK-4619] does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end

  context 'on SmartOS' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'smartos', version: 'joyent_20130111T180733Z').converge(described_recipe)
    end

    it '[COOK-4423] renders file main.cf without smtp_use_tls' do
      expect(chef_run).to render_file('/opt/local/etc/postfix/main.cf').with_content(/smtp_use_tls += +no/)
    end

    it '[COOK-4619] does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end

  context 'on Ubuntu 16.04' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: 16.04).converge(described_recipe)
    end

    it '[COOK-4423] renders file main.cf with /etc/postfix/cacert.pem' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{smtp_tls_CAfile += +/etc/ssl/certs/ca-certificates.crt})
    end

    it '[COOK-4619] does not set recipient_delimiter' do
      expect(chef_run).to_not render_file('/etc/postfix/main.cf').with_content('recipient_delimiter')
    end
  end
end
