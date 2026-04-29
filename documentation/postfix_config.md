# postfix_config

Renders `main.cf`, `master.cf`, and optional map files.

```ruby
postfix_config 'default' do
  main_settings('inet_interfaces' => 'loopback-only')
  use_alias_maps true
  aliases('root' => 'admin@example.com')
end
```
