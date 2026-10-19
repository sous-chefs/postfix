postfix 'default' do
  main_settings('smtp_sasl_auth_enable' => 'yes', 'relayhost' => '[smtp.example.com]:587')
  sasl('[smtp.example.com]:587' => { 'username' => 'postfix', 'password' => 'secret' })
end
