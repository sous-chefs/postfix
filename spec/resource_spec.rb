require 'spec_helper'

describe 'postfix resources' do
  context 'postfix_install' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_install')
    end

    it 'installs postfix' do
      expect(chef_run).to install_package(%w(postfix))
    end
  end

  context 'postfix_install on AlmaLinux 9' do
    cached(:chef_run) do
      allow(File).to receive(:identical?).and_call_original
      allow(File).to receive(:identical?).with('/etc/alternatives/mta', '/usr/sbin/sendmail.postfix').and_return(false)
      ChefSpec::SoloRunner.new(platform: 'almalinux', version: '9', step_into: postfix_step_into).converge('test::spec_install')
    end

    it 'makes postfix the system MTA' do
      expect(chef_run).to set_alternatives('mta').with(path: '/usr/sbin/sendmail.postfix')
      expect(chef_run.alternatives('mta')).to notify('service[sendmail]').to(:stop)
      expect(chef_run.alternatives('mta')).to notify('service[postfix]').to(:start)
    end
  end

  context 'postfix_install when the MTA link already resolves to postfix' do
    cached(:chef_run) do
      allow(File).to receive(:identical?).and_call_original
      allow(File).to receive(:identical?).with('/etc/alternatives/mta', '/usr/sbin/sendmail.postfix').and_return(true)
      ChefSpec::SoloRunner.new(platform: 'almalinux', version: '9', step_into: postfix_step_into).converge('test::spec_install')
    end

    it 'leaves the link alone, as on merged-sbin Fedora where it names /usr/bin' do
      expect(chef_run).to_not set_alternatives('mta')
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

    it 'rebuilds the alias database when /etc/aliases changes' do
      expect(chef_run.template('/etc/aliases')).to notify('execute[update-postfix-map-/etc/aliases]').to(:run).immediately
      expect(chef_run.execute('update-postfix-map-/etc/aliases').command).to eq('newaliases')
    end

    it 'runs newaliases when the alias database is missing' do
      expect(chef_run).to run_execute('create-postfix-map-/etc/aliases').with(command: 'newaliases', creates: '/etc/aliases.db')
    end
  end

  context 'postfix_config with aliases and an lmdb db_type' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_config_aliases_lmdb')
    end

    it 'looks for the alias database main.cf names, so newaliases does not rerun' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(%r{^alias_database = lmdb:/etc/aliases$})
      expect(chef_run).to run_execute('create-postfix-map-/etc/aliases').with(creates: '/etc/aliases.lmdb')
    end
  end

  context 'postfix_map' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_map')
    end

    it 'renders a map file' do
      expect(chef_run).to render_file('/etc/postfix/access').with_content(/^example.com OK$/)
    end

    it 'passes the map type to postmap' do
      expect(chef_run.execute('update-postfix-map-/etc/postfix/access').command).to eq('postmap hash:/etc/postfix/access')
    end

    it 'rebuilds the compiled table when it is missing' do
      expect(chef_run).to run_execute('create-postfix-map-/etc/postfix/access').with(
        command: 'postmap hash:/etc/postfix/access',
        creates: '/etc/postfix/access.db'
      )
    end
  end

  context 'postfix_map without a type on AlmaLinux 10' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'almalinux', version: '10', step_into: postfix_step_into).converge('test::spec_map')
    end

    it 'builds the platform database type, since EL10 has no hash support' do
      expect(chef_run.execute('update-postfix-map-/etc/postfix/access').command).to eq('/usr/sbin/postmap lmdb:/etc/postfix/access')
    end

    it 'looks for the lmdb file when deciding whether to rebuild' do
      expect(chef_run).to run_execute('create-postfix-map-/etc/postfix/access').with(creates: '/etc/postfix/access.lmdb')
    end
  end

  context 'postfix_map with a type postmap does not compile' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_map_regexp')
    end

    it 'does not try to rebuild a compiled file' do
      expect(chef_run).to_not run_execute('create-postfix-map-/etc/postfix/header_checks')
    end

    it 'does not run postmap on a table Postfix reads as text' do
      expect(chef_run.find_resource(:execute, 'update-postfix-map-/etc/postfix/header_checks')).to be_nil
      expect(chef_run.template('/etc/postfix/header_checks')).to_not notify('execute[update-postfix-map-/etc/postfix/header_checks]')
    end
  end

  context 'postfix_config with extra maps' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into) do
        stubs_for_provider('postfix_config[default]') do |provider|
          allow(provider).to receive(:shell_out).and_call_original
          allow(provider).to receive(:shell_out).with('postconf', '-m').and_return(double(stdout: "pcre\ntexthash\n"))
        end
      end.converge('test::spec_config_maps')
    end

    it 'manages a map whose type postconf -m lists' do
      expect(chef_run).to create_postfix_map('/etc/postfix/header_checks')
    end

    it 'skips a type postconf -m does not list, even when a listed name contains it' do
      expect(chef_run).to_not create_postfix_map('/etc/postfix/hash_map')
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

    it 'builds the access map before main.cf references it' do
      names = chef_run.resource_collection.all_resources.map(&:to_s)
      expect(names.index('template[/etc/postfix/access]')).to be < names.index('template[/etc/postfix/main.cf]')
    end
  end

  context 'postfix_config with access maps on AlmaLinux 10' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'almalinux', version: '10', step_into: postfix_step_into).converge('test::spec_config_access')
    end

    it 'passes the configured type through to postmap' do
      expect(chef_run.execute('update-postfix-map-/etc/postfix/access').command).to eq('/usr/sbin/postmap lmdb:/etc/postfix/access')
    end
  end

  context 'postfix_config with virtual aliases' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_config_virtual')
    end

    it 'builds the virtual alias map before main.cf references it' do
      names = chef_run.resource_collection.all_resources.map(&:to_s)
      expect(names.index('template[/etc/postfix/virtual]')).to be < names.index('template[/etc/postfix/main.cf]')
    end
  end

  context 'postfix with SASL relay authentication' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge('test::spec_wrapper_sasl')
    end

    it 'builds the SASL password map before main.cf references it' do
      names = chef_run.resource_collection.all_resources.map(&:to_s)
      expect(names.index('template[/etc/postfix/sasl_passwd]')).to be < names.index('template[/etc/postfix/main.cf]')
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
