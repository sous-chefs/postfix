# postfix Cookbook CHANGELOG

This file is used to list changes made in each version of the postfix cookbook.

## Unreleased

## 6.4.0 - *2025-07-30* ## 6.4.0 - *2025-07-30*

Standardise files with files in sous-chefs/repo-management

## 6.4.0 - *2025-07-30*

## 6.3.0 - *2025-07-30*

- Use LMDB instead of hash on el10

## 6.3.0 - *2025-07-30*

## 6.2.2 - *2025-01-30*

## 6.2.1 - *2025-01-30*

## 6.2.0 - *2025-01-30*

## 6.2.0

- Correctly fix aliases quoting logic
- Convert all serverspec tests to inspec
- Add Github actions
- Update platforms to test

## 6.0.29 - *2024-11-18*

- Standardise files with files in sous-chefs/repo-management

## 6.0.28 - *2024-07-15*

- Standardise files with files in sous-chefs/repo-management

## 6.0.27 - *2024-05-06*

## 6.0.26 - *2023-10-03*

- Add installation of postfix addon packages for RHEL 8

## 6.0.25 - *2023-10-03*

Fix markdown

## 6.0.24 - *2023-09-28*

Standardise files with files in sous-chefs/repo-management

## 6.0.23 - *2023-09-04*

Standardise files with files in sous-chefs/repo-management

## 6.0.22 - *2023-08-29*

Standardise files with files in sous-chefs/repo-management

## 6.0.21 - *2023-05-17*

Standardise files with files in sous-chefs/repo-management

## 6.0.20 - *2023-04-17*

Fix CI permissions

## 6.0.19 - *2023-04-17*

Standardise files with files in sous-chefs/repo-management

## 6.0.18 - *2023-04-07*

Standardise files with files in sous-chefs/repo-management

## 6.0.17 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 6.0.16 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 6.0.15 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 6.0.14 - *2023-03-20*

Standardise files with files in sous-chefs/repo-management

## 6.0.13 - *2023-03-15*

Standardise files with files in sous-chefs/repo-management

## 6.0.12 - *2023-02-23*

Standardise files with files in sous-chefs/repo-management

## 6.0.11 - *2023-02-16*

Standardise files with files in sous-chefs/repo-management

## 6.0.10 - *2023-02-14*

Standardise files with files in sous-chefs/repo-management

## 6.0.9 - *2023-02-14*

Standardise files with files in sous-chefs/repo-management

## 6.0.8 - *2022-12-08*

Standardise files with files in sous-chefs/repo-management

## 6.0.7 - *2022-02-03*

Standardise files with files in sous-chefs/repo-management

## 6.0.6 - *2022-02-02*

- Update tested platforms
- Remove delivery and move to calling RSpec directly via a reusable workflow

## 6.0.5 - *2022-01-08*

- resolved cookstyle error: test/integration/helpers/serverspec/spec_helper.rb:9:21 convention: `Style/FileRead`

## 6.0.4 - *2021-08-19*

## 6.0.3 - *2021-08-19*

- Fixed TLS configuration

## 6.0.2 - *2021-06-30*

- Make sure we write the main.conf and master.conf before we try to use any commands (like postmap)

## 6.0.1 - *2021-06-01*

## 6.0.0 - *2020-11-23*

- Disabled SSLv3 by default

## 5.4.1 - 2020-10-20

- Ensure all postmap files are rebuilt immediately if needed

## 5.4.0 - 2020-10-11

### Changed

- Sous Chefs Adoption
- Update to use Sous Chefs GH workflow
- Update README to sous-chefs
- Update metadata.rb to Sous Chefs
- Update test-kitchen to Sous Chefs

### Added

- Standardise files with files in sous-chefs/repo-management
- Add Ubuntu 20.04 testing

### Fixed

- Cookstyle fixes
- ChefSpec fixes
- Yamllint fixes
- MDL fixes
- Fix OpenSUSE installation issues

### Removed

- Remove EL 6 testing
- Remove Amazon Linux 1 testing

## 5.3.1 (2018-07-24)

- Fixed sbin issue with Chef13

## 5.3.0 (2018-05-23)

- support multiple sasl_passwd entries
- Add `packages` attribute so different postfix packages can be installed
- add ability to set network connection port for a remote relayhost

## 5.2.1 (2017-11-22)

- Properly support FreeBSD
- Do not run service restart for solaris which fails

## 5.2.0 (2017-08-07)

- Lazily evaluate the config template variables to allow overrides to properly apply
- Avoid Chefspec deprecation warnings

## 5.1.1 (2017-07-28)

- Fix support for Amazon Linux on Chef 13
- Expand testing to cover Debian 9 in Travis

## 5.1.0 (2017-07-28)

- Add an option to allow recipient canonical maps

## 5.0.3 (2017-06-26)

- Correct attribute line for use_relay_restrictions_maps to prevent converge failures

## 5.0.2 (2017-05-17)

- Fix use_relay_restrictions_maps attribute misspelling in attributes file

## 5.0.1 (2017-03-03)

- Fix documentation error on inet-interfaces
- Test with Local Delivery instead of Rake
- Fix master.cf attributes types on README

## 5.0.0 (2017-01-17)

- Manage any hash: tables for postfix with hash_maps recipe
- Fully customizable master.cf file
- Support for any kind of postfix lookup tables
- Remove old minitest files
- Update chef requirement in the readme
- Update tests for new config comment blocks
- fixing /etc/aliases syntax for full-mailaddresses

## 4.0.0 (2016-09-07)

- Update supported platforms in metadata
- Remove node name from config file
- Testing updates
- Use node.normal vs. node.set to avoid deprecation warnings
- Require Chef 12+

## v3.8.0 (2016-04-01)

- Updated attributes to use  node.default_unless instead of node.default to be more wrapper friendly
- Added integration and unit testing in Travis CI
- Added rubocop config and resolved rubocop warnings
- Added Gemfile with all necessary test deps
- Added standard gitignore and chefignore files
- Added updated contributing and testing docs
- Removed the Kitchen Digital Ocean files and dependencies
- Added additional platforms to the Test Kitchen config
- Added a Rakefile for simplified testing
- Fixed a typo in the use_relay_restrictions_maps attribute that prevented the default from being set
- Added fedora and oracle as supported platforms in the metadata
- Removed the attributes from the metadata.
- Added long_description to the metadata
- Added Chef 11 compatibility checks to issues_url and source_url in metadata.rb
- Added maintainers.md and maintainers.toml files

## v3.7.0 (2015-04-30)

- Adding support for relay restrictions
- Update chefspec and serverspec tests

## v3.6.2 (2014-10-31)

- Fix FreeBSDisms

## v3.6.1 (2014-10-28)

- Fix documentation around node['postfix']['main']['relayhost'] attribute
- Fix logic around include_recipe 'postfix::virtual_aliases_domains'

## v3.6.0 (2014-08-25)

- restart postfix after updating virtual alias templates #86
- fixing typo for alias_db location in omnios
- moving conditional attributes to a recipe so they can be modified
- via other cookbook attributes

## v3.5.0 (2014-08-25)

Adding virtual_domains functionality

## v3.4.1 (2014-08-20)

Removing unused parameters from main.cf

## v3.4.0 (2014-07-25)

Refactoring to fix some logic issues

## v3.3.1 (2014-06-11)

Reverting #37 - [COOK-3418] Virtual Domain Support PR - duplicate of #55

## v3.3.0 (2014-06-11)

- 37 - [COOK-3418] - Virtual Domain Support
- 44 - Fix minor formatting issue in attributes
- 55 - Add support for virtual aliases
- 57 - Fixing attributes bug in README
- 64 - add smtp_generic maps configuration option
- 66 - [COOK-3652] Add support for transport mappings
- 67 - [COOK-4662] Added support for access control
- 68 - Properly handle binding to loopback on mixed IPV4/IPV6 systems

## v3.2.0 (2014-05-09)

- [COOK-4619] - no way to unset recipient_delimiter

## v3.1.8 (2014-03-27)

- [COOK-4410] - Fix sender_canonical configuration by adding template
- and postmap execution

## v3.1.6 (2014-03-19)

- [COOK-4423] - use platform_family, find cert.pem on rhel

## v3.1.4 (2014-02-27)

[COOK-4329] Migrate minitest PITs to latest test-kitchen + serverspec

## v3.1.2 (2014-02-19)

### Bug

- postfix::sasl_auth recipe fails to converge

## v3.1.0 (2014-02-19)

### Bug

- Postfix cookbook has incorrect default path for sasl_passwd

### New Feature

- use conf_dir attribute for sasl recipe, and add omnios support
- Support creating the sender_canonical map file

## v3.0.4

### Bug

- main.cf.erb mishandles lists

### Improvement

- postfix cookbook readme has an incorrect example
- Got rubocop errors down to 32

### New Feature

- Support creating the sender_canonical map file

## v3.0.2

### Bug

- Fix error when no there is no FQDN
- Update `client.rb` after 3.0.0 refactor
- Do not use resource cloning

### Improvement

- Add SmartOS support

## v3.0.0

### Improvement

- Postfix main/master and attributes refactor

**Breaking changes**:

- Attributes are namespaced as `node['postfix']`, `node['postfix']['main']`, and `node['postfix']['master']`.

## v2.1.6

### Bug

- [COOK-2501]: Reference to `['postfix']['domain']` should be `['postfix']['mydomain']`
- [COOK-2715]: master.cf uses old name for `smtp_fallback_relay` (`fallback_relay`) parameter in master.cf

## v2.1.4

- [COOK-2281] - postfix aliases uses require_recipe statement

## v2.1.2

- [COOK-2010] - postfix sasl_auth does not include the sasl plain package

## v2.1.0

- [COOK-1233] - optional configuration for canonical maps
- [COOK-1660] - allow comma separated arrays in aliases
- [COOK-1662] - allow inet_interfaces configuration via attribute

## v2.0.0

This version uses platform_family attribute, making the cookbook incompatible with older versions of Chef/Ohai, hence the major version bump.

- [COOK-1535] - `smtpd_cache` should be in `data_directory`, not `queue_directory`
- [COOK-1790] - /etc/aliases template is only in ubuntu directory
- [COOK-1792] - add minitest-chef tests to postfix cookbook

## v1.2.2

- [COOK-1442] - Missing ['postfix']['domain'] Attribute causes initial installation failure
- [COOK-1520] - Add support for procmail delivery
- [COOK-1528] - Make aliasses template less specific
- [COOK-1538] - Add iptables_rule template
- [COOK-1540] - Add smtpd_milters and non_smtpd_milters parameters to main.cf

## v1.2.0

- [COOK-880] - add client/server roles for search-based discovery of relayhost

## v1.0.0

- [COOK-668] - RHEL/CentOS/Scientific/Amazon platform support
- [COOK-733] - postfix::aliases recipe to manage /etc/aliases
- [COOK-821] - add README.md :)

## v0.8.4

- Current public release.
