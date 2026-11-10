postfix_map '/etc/postfix/header_checks' do
  type 'regexp'
  content('/^Subject: spam/' => 'REJECT')
end
