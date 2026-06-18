# frozen_string_literal: true

#
# Cookbook:: postfix
# Library:: helpers
#

module PostfixCookbook
  module Helpers
    POSTMAP_DATABASE_TYPES = %w(btree cdb dbm hash lmdb sdbm).freeze
    PACKAGE_MAP_TYPES = %w(pgsql mysql ldap cdb lmdb).freeze
    EQUAL_SEPARATOR_MAP_TYPES = %w(pgsql mysql ldap memcache sqlite).freeze

    def postfix_node_config
      node['postfix'] || {}
    rescue NoMethodError
      {}
    end

    def postfix_setting(key, default = nil)
      postfix_node_config.key?(key.to_s) ? postfix_node_config[key.to_s] : default
    end

    def postfix_main_setting(key, default = nil)
      settings = postfix_setting('main', {})
      settings.key?(key.to_s) ? settings[key.to_s] : default
    end

    def postfix_master_setting(key, default = nil)
      settings = postfix_setting('master', {})
      settings.key?(key.to_s) ? settings[key.to_s] : default
    end

    def postfix_packages
      postfix_setting('packages') || default_postfix_packages
    end

    def default_postfix_packages
      return %w(postfix postfix-lmdb) if platform?('amazon') && node['platform_version'].to_i >= 2023

      %w(postfix)
    end

    def postfix_db_type
      postfix_setting('db_type') || default_postfix_db_type
    end

    def default_postfix_db_type
      return 'lmdb' if platform?('amazon') && node['platform_version'].to_i >= 2023
      return 'lmdb' if platform_family?('rhel') && node['platform_version'].to_i >= 10
      return 'lmdb' if platform_family?('suse') && node['platform_version'].to_i >= 15

      'hash'
    end

    def postfix_paths
      if platform?('freebsd')
        return {
          conf_dir: '/usr/local/etc/postfix',
          aliases_db: '/etc/aliases',
          transport_db: '/usr/local/etc/postfix/transport',
          access_db: '/usr/local/etc/postfix/access',
          virtual_alias_db: '/usr/local/etc/postfix/virtual',
          virtual_alias_domains_db: '/usr/local/etc/postfix/virtual_domains',
          relay_restrictions_db: '/etc/postfix/relay_restrictions',
        }
      end

      {
        conf_dir: '/etc/postfix',
        aliases_db: '/etc/aliases',
        transport_db: '/etc/postfix/transport',
        access_db: '/etc/postfix/access',
        virtual_alias_db: '/etc/postfix/virtual',
        virtual_alias_domains_db: '/etc/postfix/virtual_domains',
        relay_restrictions_db: '/etc/postfix/relay_restrictions',
      }
    end

    def postfix_path(key)
      postfix_setting(key.to_s) || postfix_paths[key]
    end

    def postfix_cafile(conf_dir = postfix_path(:conf_dir))
      postfix_setting('cafile') || case node['platform_family']
                                   when 'debian'
                                     '/etc/ssl/certs/ca-certificates.crt'
                                   when 'rhel', 'amazon'
                                     '/etc/pki/tls/cert.pem'
                                   else
                                     "#{conf_dir}/cacert.pem"
                                   end
    end

    def postfix_default_main_settings(_conf_dir: postfix_path(:conf_dir), db_type: postfix_db_type)
      hostname = (node['hostname'] || 'localhost').to_s.chomp('.')
      fqdn = (node['fqdn'] || hostname).to_s.chomp('.')
      domain = (node['domain'] || hostname).to_s.chomp('.')

      settings = {
        'biff' => 'no',
        'append_dot_mydomain' => 'no',
        'myhostname' => fqdn,
        'mydomain' => domain,
        'myorigin' => '$myhostname',
        'mydestination' => [fqdn, hostname, 'localhost.localdomain', 'localhost'].compact,
        'smtpd_use_tls' => 'yes',
        'smtp_use_tls' => 'yes',
        'smtpd_tls_mandatory_protocols' => '!SSLv2,!SSLv3',
        'smtp_tls_mandatory_protocols' => '!SSLv2,!SSLv3',
        'smtpd_tls_protocols' => '!SSLv2,!SSLv3',
        'smtp_tls_protocols' => '!SSLv2,!SSLv3',
        'smtp_sasl_auth_enable' => 'no',
        'mailbox_size_limit' => 0,
        'mynetworks' => nil,
        'inet_interfaces' => 'loopback-only',
        'default_database_type' => db_type,
        'alias_database' => "#{db_type}:#{postfix_path(:aliases_db)}",
        'alias_maps' => "#{db_type}:#{postfix_path(:aliases_db)}",
      }

      if platform_family?('suse')
        settings['setgid_group'] = 'maildrop'
        settings['daemon_directory'] = '/usr/lib/postfix/bin'
      end

      settings.merge(postfix_setting('main', {}).to_h)
    end

    def postfix_derived_main_settings(settings, conf_dir:, db_type:, use_procmail:, use_alias_maps:, use_transport_maps:, use_virtual_aliases:, use_virtual_aliases_domains:, use_relay_restrictions_maps:)
      settings = settings.dup
      cafile = postfix_cafile(conf_dir)

      settings['mailbox_command'] ||= '/usr/bin/procmail -a "$EXTENSION"' if use_procmail
      if settings['smtpd_use_tls'] == 'yes'
        settings['smtpd_tls_cert_file'] ||= '/etc/ssl/certs/ssl-cert-snakeoil.pem'
        settings['smtpd_tls_key_file'] ||= '/etc/ssl/private/ssl-cert-snakeoil.key'
        settings['smtpd_tls_CAfile'] ||= cafile
        settings['smtpd_tls_session_cache_database'] ||= 'btree:${data_directory}/smtpd_scache'
      end
      if settings['smtp_use_tls'] == 'yes'
        settings['smtp_tls_CAfile'] ||= cafile
        settings['smtp_tls_session_cache_database'] ||= 'btree:${data_directory}/smtp_scache'
      end
      if settings['smtp_sasl_auth_enable'] == 'yes'
        settings['smtp_sasl_password_maps'] ||= "#{db_type}:#{postfix_sasl_password_file(conf_dir)}"
        settings['smtp_sasl_security_options'] ||= 'noanonymous'
        settings['relayhost'] ||= ''
      end

      settings['alias_maps'] ||= ["#{db_type}:#{postfix_path(:aliases_db)}"] if use_alias_maps
      settings['transport_maps'] ||= ["#{db_type}:#{postfix_path(:transport_db)}"] if use_transport_maps
      settings['virtual_alias_maps'] ||= ["#{postfix_setting('virtual_alias_db_type') || db_type}:#{postfix_path(:virtual_alias_db)}"] if use_virtual_aliases
      settings['virtual_alias_domains'] ||= ["#{postfix_setting('virtual_alias_domains_db_type') || db_type}:#{postfix_path(:virtual_alias_domains_db)}"] if use_virtual_aliases_domains
      settings['smtpd_relay_restrictions'] ||= "#{db_type}:#{postfix_path(:relay_restrictions_db)}, reject" if use_relay_restrictions_maps

      master = postfix_default_master_settings.merge(postfix_setting('master', {}).to_h)
      settings['maildrop_destination_recipient_limit'] ||= 1 if master.dig('maildrop', 'active')
      settings['cyrus_destination_recipient_limit'] ||= 1 if master.dig('cyrus', 'active')

      settings
    end

    def postfix_default_master_settings
      {
        'smtp' => { 'active' => true, 'order' => 10, 'type' => 'inet', 'private' => false, 'chroot' => false, 'command' => 'smtpd', 'args' => [] },
        'submission' => { 'active' => false, 'order' => 20, 'type' => 'inet', 'private' => false, 'chroot' => false, 'command' => 'smtpd', 'args' => ['-o smtpd_enforce_tls=yes', ' -o smtpd_sasl_auth_enable=yes', '-o smtpd_client_restrictions=permit_sasl_authenticated,reject'] },
        'smtps' => { 'active' => false, 'order' => 30, 'type' => 'inet', 'private' => false, 'chroot' => false, 'command' => 'smtpd', 'args' => ['-o smtpd_tls_wrappermode=yes', '-o smtpd_sasl_auth_enable=yes', '-o smtpd_client_restrictions=permit_sasl_authenticated,reject'] },
        '628' => { 'active' => false, 'order' => 40, 'type' => 'inet', 'private' => false, 'chroot' => false, 'command' => 'qmqpdd', 'args' => [] },
        'pickup' => { 'active' => true, 'order' => 50, 'type' => 'fifo', 'private' => false, 'chroot' => false, 'wakeup' => '60', 'maxproc' => '1', 'command' => 'pickup', 'args' => [] },
        'cleanup' => { 'active' => true, 'order' => 60, 'type' => 'unix', 'private' => false, 'chroot' => false, 'maxproc' => '0', 'command' => 'cleanup', 'args' => [] },
        'qmgr' => { 'active' => true, 'order' => 70, 'type' => 'fifo', 'private' => false, 'chroot' => false, 'wakeup' => '300', 'maxproc' => '1', 'command' => 'qmgr', 'args' => [] },
        'tlsmgr' => { 'active' => true, 'order' => 80, 'type' => 'unix', 'chroot' => false, 'wakeup' => '1000?', 'maxproc' => '1', 'command' => 'tlsmgr', 'args' => [] },
        'rewrite' => { 'active' => true, 'order' => 90, 'type' => 'unix', 'chroot' => false, 'command' => 'trivial-rewrite', 'args' => [] },
        'bounce' => { 'active' => true, 'order' => 100, 'type' => 'unix', 'chroot' => false, 'maxproc' => '0', 'command' => 'bounce', 'args' => [] },
        'defer' => { 'active' => true, 'order' => 110, 'type' => 'unix', 'chroot' => false, 'maxproc' => '0', 'command' => 'bounce', 'args' => [] },
        'trace' => { 'active' => true, 'order' => 120, 'type' => 'unix', 'chroot' => false, 'maxproc' => '0', 'command' => 'bounce', 'args' => [] },
        'verify' => { 'active' => true, 'order' => 130, 'type' => 'unix', 'chroot' => false, 'maxproc' => '1', 'command' => 'verify', 'args' => [] },
        'flush' => { 'active' => true, 'order' => 140, 'type' => 'unix', 'private' => false, 'chroot' => false, 'wakeup' => '1000?', 'maxproc' => '0', 'command' => 'flush', 'args' => [] },
        'proxymap' => { 'active' => true, 'order' => 150, 'type' => 'unix', 'chroot' => false, 'command' => 'proxymap', 'args' => [] },
        'smtpunix' => { 'service' => 'smtp', 'active' => true, 'order' => 160, 'type' => 'unix', 'chroot' => false, 'maxproc' => '500', 'command' => 'smtp', 'args' => [] },
        'relay' => { 'active' => true, 'comment' => 'When relaying mail as backup MX, disable fallback_relay to avoid MX loops', 'order' => 170, 'type' => 'unix', 'chroot' => false, 'command' => 'smtp', 'args' => ['-o smtp_fallback_relay='] },
        'showq' => { 'active' => true, 'order' => 180, 'type' => 'unix', 'private' => false, 'chroot' => false, 'command' => 'showq', 'args' => [] },
        'error' => { 'active' => true, 'order' => 190, 'type' => 'unix', 'chroot' => false, 'command' => 'error', 'args' => [] },
        'discard' => { 'active' => true, 'order' => 200, 'type' => 'unix', 'chroot' => false, 'command' => 'discard', 'args' => [] },
        'local' => { 'active' => true, 'order' => 210, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'local', 'args' => [] },
        'virtual' => { 'active' => true, 'order' => 220, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'virtual', 'args' => [] },
        'lmtp' => { 'active' => true, 'order' => 230, 'type' => 'unix', 'chroot' => false, 'command' => 'lmtp', 'args' => [] },
        'anvil' => { 'active' => true, 'order' => 240, 'type' => 'unix', 'chroot' => false, 'maxproc' => '1', 'command' => 'anvil', 'args' => [] },
        'scache' => { 'active' => true, 'order' => 250, 'type' => 'unix', 'chroot' => false, 'maxproc' => '1', 'command' => 'scache', 'args' => [] },
        'maildrop' => { 'active' => true, 'comment' => 'See the Postfix MAILDROP_README file for details. To main.cf will be added: maildrop_destination_recipient_limit=1', 'order' => 510, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'pipe', 'args' => ['flags=DRhu user=vmail argv=/usr/local/bin/maildrop -d ${recipient}'] },
        'old-cyrus' => { 'active' => false, 'comment' => 'The Cyrus deliver program has changed incompatibly, multiple times.', 'order' => 520, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'pipe', 'args' => ['flags=R user=cyrus argv=/usr/lib/cyrus-imapd/deliver -e -m ${extension} ${user}'] },
        'cyrus' => { 'active' => true, 'comment' => 'Cyrus 2.1.5 (Amos Gouaux). To main.cf will be added: cyrus_destination_recipient_limit=1', 'order' => 530, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'pipe', 'args' => ['user=cyrus argv=/usr/lib/cyrus-imapd/deliver -e -r ${sender} -m ${extension} ${user}'] },
        'uucp' => { 'active' => true, 'comment' => 'See the Postfix UUCP_README file for configuration details.', 'order' => 540, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'pipe', 'args' => ['flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)'] },
        'ifmail' => { 'active' => false, 'order' => 550, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'pipe', 'args' => ['flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)'] },
        'bsmtp' => { 'active' => true, 'order' => 560, 'type' => 'unix', 'unpriv' => false, 'chroot' => false, 'command' => 'pipe', 'args' => ['flags=Fq. user=foo argv=/usr/local/sbin/bsmtp -f $sender $nexthop $recipient'] },
      }
    end

    def postfix_aliases
      postfix_setting('aliases') || default_postfix_aliases
    end

    def default_postfix_aliases
      return {} unless platform?('freebsd')

      {
        'MAILER-DAEMON' => 'postmaster',
        'bin' => 'root',
        'daemon' => 'root',
        'named' => 'root',
        'nobody' => 'root',
        'uucp' => 'root',
        'www' => 'root',
        'ftp-bugs' => 'root',
        'postfix' => 'root',
        'manager' => 'root',
        'dumper' => 'root',
        'operator' => 'root',
        'abuse' => 'postmaster',
      }
    end

    def postfix_sasl_password_file(conf_dir = postfix_path(:conf_dir))
      postfix_setting('sasl_password_file') || "#{conf_dir}/sasl_passwd"
    end

    def postfix_sasl_packages
      case node['platform_family']
      when 'debian'
        %w(libsasl2-2 libsasl2-modules ca-certificates)
      when 'rhel', 'amazon', 'fedora'
        %w(cyrus-sasl cyrus-sasl-plain ca-certificates)
      else
        []
      end
    end

    def postfix_path_environment
      { 'PATH' => "#{ENV['PATH']}:/opt/omni/bin:/opt/omni/sbin" }
    end

    def postfix_postmap_command
      platform_family?('rhel') ? '/usr/sbin/postmap' : 'postmap'
    end

    def postfix_map_separator(type)
      EQUAL_SEPARATOR_MAP_TYPES.include?(type) ? ' = ' : ' '
    end
  end
end
