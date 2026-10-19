# postfix_sasl_auth

Installs SASL support packages and manages the sensitive `sasl_passwd` map, built with
`db_type` or the platform's database type so it matches `smtp_sasl_password_maps`.
When used without the `postfix` resource, give it the same `db_type` as `postfix_config`.

```ruby
postfix_sasl_auth 'default' do
  sasl(
    '[smtp.example.com]:587' => {
      'username' => 'postfix',
      'password' => 'secret',
    }
  )
end
```
