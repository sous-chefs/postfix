recipient_canonical =
  case os.family
  when 'suse'
    '/etc/postfix/recipient_canonical.lmdb'
  else
    '/etc/postfix/recipient_canonical.db'
  end

control 'canonical' do
  describe file recipient_canonical do
    it { should be_file }
  end

  describe file '/etc/postfix/main.cf' do
    its('content') { should match(%r{^\s*recipient_canonical_maps\s*=.*\/etc\/postfix\/recipient_canonical\s*$}) }
  end
end
