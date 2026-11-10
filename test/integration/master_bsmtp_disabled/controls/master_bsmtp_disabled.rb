include_controls 'default'

control 'master_bsmtp_disabled' do
  describe file '/etc/postfix/master.cf' do
    its('content') { should_not match(/^bsmtp\s/) }
    its('content') { should match(/^smtp\s+inet/) }
  end
end
