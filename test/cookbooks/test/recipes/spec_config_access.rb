postfix_config 'default' do
  use_access_maps true
  access 'example.com' => 'OK'
end
