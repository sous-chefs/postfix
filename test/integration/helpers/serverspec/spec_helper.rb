require 'serverspec'

set :backend, :exec
set :path, '/sbin:/usr/local/sbin:$PATH'

def which_family
  fam = 'solaris2'
  return fam unless File.exist? '/etc/release'
  File.open('/etc/release') do |file|
    while line = file.gets
      case line
      when /^\s*(OmniOS)/
        fam = 'omnios'
      end
    end
  end
  fam
end

def postfix_conf_path
  if os[:family] == 'solaris' && which_family == 'omnios'
    '/opt/omni/etc/postfix/'
  else
    '/etc/postfix'
  end
end
