require 'serverspec'

set :backend, :exec
set :path, '/sbin:/usr/local/sbin:$PATH'

def family
  fam = 'solaris2'
  return fam unless File.exist? '/etc/release'
  fam = 'omnios' if File.open('/etc/release').read =~ /^\s*(OmniOS)/
  fam
end

def postfix_conf_path
  if os[:family] == 'solaris' && family == 'omnios'
    '/opt/omni/etc/postfix/'
  else
    '/etc/postfix'
  end
end
