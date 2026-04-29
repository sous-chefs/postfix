# Postfix Cookbook Limitations

This cookbook manages Postfix through operating system packages and service/configuration files. It does not build Postfix from source.

Postfix upstream develops primarily on FreeBSD and Linux, with occasional Solaris testing. The upstream source can run on many UNIX-like systems, but package availability and service behavior are owned by each OS distribution.

Supported cookbook platforms are limited to current package-based Linux distributions declared in `metadata.rb` and Kitchen: AlmaLinux, Amazon Linux, Debian, Fedora, openSUSE Leap, Oracle Linux, Red Hat, Rocky Linux, and Ubuntu.

FreeBSD, SmartOS, Scientific Linux, and legacy CentOS releases were removed from cookbook support during the resource migration because the current cookbook test matrix and service implementation are Linux/package oriented.

Map backends depend on distribution packages and Postfix module availability. The `postfix_map` resource only runs `postmap` for database-backed map types such as `hash`, `lmdb`, `btree`, `cdb`, `dbm`, and `sdbm`.

Sources:

* [Postfix home page](https://www.postfix.org/)
* [Postfix installation from source](https://www.postfix.org/INSTALL.html)
* [Postfix packages and ports](https://www.postfix.org/packages.html)
