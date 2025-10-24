# Copyright:: 2012-2019, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.default_unless['postfix']['main']['mailbox_command'] = '/usr/bin/procmail -a "$EXTENSION"' if node['postfix']['use_procmail']

if node['postfix']['main']['smtpd_use_tls'] == 'yes'
  node.default_unless['postfix']['main']['smtpd_tls_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  node.default_unless['postfix']['main']['smtpd_tls_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key'
  node.default_unless['postfix']['main']['smtpd_tls_CAfile'] = node['postfix']['cafile']
  node.default_unless['postfix']['main']['smtpd_tls_session_cache_database'] = 'btree:${data_directory}/smtpd_scache'
end

if node['postfix']['main']['smtp_use_tls'] == 'yes'
  node.default_unless['postfix']['main']['smtp_tls_CAfile'] = node['postfix']['cafile']
  node.default_unless['postfix']['main']['smtp_tls_session_cache_database'] = 'btree:${data_directory}/smtp_scache'
end

if node['postfix']['main']['smtp_sasl_auth_enable'] == 'yes'
  node.default_unless['postfix']['sasl_password_file'] = "#{node['postfix']['conf_dir']}/sasl_passwd"
  node.default_unless['postfix']['main']['smtp_sasl_password_maps'] = "#{node['postfix']['db_type']}:#{node['postfix']['sasl_password_file']}"
  node.default_unless['postfix']['main']['smtp_sasl_security_options'] = 'noanonymous'
  node.default_unless['postfix']['main']['relayhost'] = ''
end

node.default_unless['postfix']['main']['alias_maps'] = ["#{node['postfix']['db_type']}:#{node['postfix']['aliases_db']}"] if node['postfix']['use_alias_maps']

node.default_unless['postfix']['main']['transport_maps'] = ["#{node['postfix']['db_type']}:#{node['postfix']['transport_db']}"] if node['postfix']['use_transport_maps']

node.default_unless['postfix']['main']['access_maps'] = ["#{node['postfix']['db_type']}:#{node['postfix']['access_db']}"] if node['postfix']['use_access_maps']

node.default_unless['postfix']['main']['virtual_alias_maps'] = ["#{node['postfix']['virtual_alias_db_type']}:#{node['postfix']['virtual_alias_db']}"] if node['postfix']['use_virtual_aliases']

node.default_unless['postfix']['main']['virtual_alias_domains'] = ["#{node['postfix']['virtual_alias_domains_db_type']}:#{node['postfix']['virtual_alias_domains_db']}"] if node['postfix']['use_virtual_aliases_domains']

node.default_unless['postfix']['main']['smtpd_relay_restrictions'] = "#{node['postfix']['db_type']}:#{node['postfix']['relay_restrictions_db']}, reject" if node['postfix']['use_relay_restrictions_maps']

node.default_unless['postfix']['main']['maildrop_destination_recipient_limit'] = 1 if node['postfix']['master']['maildrop']['active']

node.default_unless['postfix']['main']['cyrus_destination_recipient_limit'] = 1 if node['postfix']['master']['cyrus']['active']
