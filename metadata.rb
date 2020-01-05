name 'postfix'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Installs and configures postfix for client or outbound relayhost, or to do SASL auth'
version '5.3.1'

%w(ubuntu debian redhat centos amazon oracle scientific smartos fedora freebsd).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/postfix'
issues_url 'https://github.com/chef-cookbooks/postfix/issues'
chef_version '>= 12.15'
