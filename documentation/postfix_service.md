# postfix_service

Manages the Postfix service.

```ruby
postfix_service 'postfix' do
  action [:enable, :start]
end
```

Actions: `:enable`, `:start`, `:restart`, `:reload`, `:stop`, and `:disable`.
