# Migration Guide

This release removes `recipes/` and `attributes/` in favor of custom resources.

Use `postfix 'default'` in a wrapper cookbook to install packages, render `main.cf` and `master.cf`, manage optional maps, configure SASL when enabled, and enable/start the service.

Common recipe replacements:

* `recipe[postfix]` -> `postfix 'default'`
* `recipe[postfix::server]` -> `postfix_server 'default'`
* `recipe[postfix::client]` -> `postfix_client 'default'`
* `recipe[postfix::sasl_auth]` -> `postfix_sasl_auth 'default'`
* `recipe[postfix::aliases]` -> `postfix_config 'default'` with `use_alias_maps true`
* map recipes -> `postfix_map`

Most legacy `node['postfix']` attributes are still read by the resources to ease wrapper cookbook migration, but new code should pass resource properties directly.

Example:

```ruby
postfix 'default' do
  main_settings(
    'relayhost' => '[smtp.example.com]:587',
    'smtp_sasl_auth_enable' => 'yes'
  )
  sasl(
    '[smtp.example.com]:587' => {
      'username' => 'postfix',
      'password' => 'secret',
    }
  )
end
```
