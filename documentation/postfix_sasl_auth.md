# postfix_sasl_auth

Installs SASL support packages and manages the sensitive `sasl_passwd` map.

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
