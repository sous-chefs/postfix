include_recipe 'test::net_setup'

postfix 'access' do
  use_access_maps true
  access 'example.com' => 'OK'
end
