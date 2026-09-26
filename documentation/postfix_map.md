# postfix_map

Manages a Postfix lookup table and optionally runs `postmap`. For the database
types `postmap` builds, the command names the type (`postmap hash:/etc/postfix/access`),
so the table does not depend on `default_database_type` in `main.cf`.

`type` defaults to `db_type`, then to the platform's database type: `lmdb` on
EL 10+, Amazon Linux 2023 and SUSE 15+, `hash` elsewhere. EL 10 and SUSE 15 build
Postfix without Berkeley DB, so `hash` and `btree` tables fail there.

The table is rebuilt when its source changes and also whenever the compiled file
(`.db`, `.lmdb`, `.cdb` or `.pag`) is missing, so a deleted database comes back on
the next converge.

```ruby
postfix_map '/etc/postfix/access' do
  content('example.com' => 'OK')
end
```
