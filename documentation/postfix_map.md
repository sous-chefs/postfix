# postfix_map

Manages a Postfix lookup table and optionally runs `postmap`.

```ruby
postfix_map '/etc/postfix/access' do
  type 'hash'
  content('example.com' => 'OK')
end
```
