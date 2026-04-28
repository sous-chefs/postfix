# postfix_client

Uses Chef Server search to discover a relay host and then converges `postfix`.

```ruby
postfix_client 'default' do
  relayhost_role 'relayhost'
  relayhost_port 25
end
```
