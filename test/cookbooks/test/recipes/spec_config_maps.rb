postfix_config 'default' do
  maps(
    'pcre' => { '/etc/postfix/header_checks' => { '/^Subject: spam/' => 'REJECT' } },
    'hash' => { '/etc/postfix/hash_map' => { 'example.com' => 'OK' } }
  )
end
