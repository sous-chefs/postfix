require_recipe "postfix"

execute "update-postfix-virtual" do
  command "postmap /etc/postfix/virtual"
  action :nothing
end

template "/etc/postfix/virtual" do
  source "virtual.erb"
  notifies :run, resources("execute[update-postfix-virtual]")
end

