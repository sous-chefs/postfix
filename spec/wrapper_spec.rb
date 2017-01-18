require 'spec_helper'

##
# Spec to ensure wrapper cookbook can correctly override
# attributes using default level without _attributes
# recipe clearing them.

describe 'test::default' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: 16.04).converge(described_recipe)
  end

  describe '_attributes recipes' do
    it 'keeps wrapper cookbook default set attributes' do
      expect(chef_run.node['postfix']['main']['relayhost']).to eq('please')
      expect(chef_run.node['postfix']['main']['smtp_sasl_security_options']).to eq('keep')
      expect(chef_run.node['postfix']['sasl']['smtp_sasl_user_name']).to eq('us')
      expect(chef_run.node['postfix']['sasl']['smtp_sasl_passwd']).to eq('happy')
    end
  end
end
