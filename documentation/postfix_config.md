# postfix_config

Renders `main.cf`, `master.cf`, and optional map files. Map files are built before
`main.cf` is rendered so Postfix never references a table that does not exist yet;
the aliases table follows `main.cf` because `newaliases` reads `alias_database` from it.
The `postfix` resource likewise runs `postfix_sasl_auth` before `postfix_config`.

```ruby
postfix_config 'default' do
  main_settings('inet_interfaces' => 'loopback-only')
  use_alias_maps true
  aliases('root' => 'admin@example.com')
end
```
