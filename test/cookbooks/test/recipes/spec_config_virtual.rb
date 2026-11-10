postfix_config 'default' do
  use_virtual_aliases true
  virtual_aliases 'root@example.com' => 'admin@example.com'
end
