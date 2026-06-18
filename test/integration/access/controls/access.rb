include_controls 'default'

control 'access' do
  describe file '/etc/postfix/access' do
    it { should exist }
    its('content') { should match(/^example.com OK$/) }
  end

  # access(5) maps are consulted via check_*_access lookups, not as a
  # standalone main.cf parameter. Ensure we never write a bogus
  # access_maps setting (regression test for the 7.0.0 rewrite).
  describe file '/etc/postfix/main.cf' do
    its('content') { should_not match(/access_maps/) }
  end

  # postconf warns about unused parameters; a clean check must be silent.
  describe command('postconf -n 2>&1 >/dev/null') do
    its('stdout') { should_not match(/access_maps/) }
  end
end
