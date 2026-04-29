# postfix

Installs, configures, and starts Postfix.

```ruby
postfix 'default' do
  main_settings('relayhost' => '[smtp.example.com]')
end
```

Useful properties include `main_settings`, `master_settings`, `use_alias_maps`, `use_transport_maps`, `use_access_maps`, `use_virtual_aliases`, `use_virtual_aliases_domains`, `use_relay_restrictions_maps`, `aliases`, `transports`, `access`, `virtual_aliases`, `virtual_aliases_domains`, `maps`, and `sasl`.
