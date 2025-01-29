include_controls 'default'

control 'server' do
  describe file '/etc/postfix/main.cf' do
    its('content') { should match /Configured as master/ }
  end
end
