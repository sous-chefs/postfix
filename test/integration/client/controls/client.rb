include_controls 'default'

control 'client' do
  describe file '/etc/postfix/main.cf' do
    its('content') { should match /Configured as client/ }
  end
end
