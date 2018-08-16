default['postfix']['main']['smtp_sasl_auth_enable'] = 'yes'
default['postfix']['main']['relayhost'] = 'please'
default['postfix']['main']['smtp_sasl_security_options'] = 'keep'
default['postfix']['sasl'] = { 'please' => { 'username' => 'us', 'password' => 'happy' } }
default['postfix']['sender_canonical_map_entries'] = {}
