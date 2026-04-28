# postfix_install

Installs Postfix packages and performs platform mailer switching where supported.

```ruby
postfix_install 'default' do
  packages %w(postfix postfix-lmdb)
  use_procmail false
end
```
