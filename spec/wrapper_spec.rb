require 'spec_helper'

##
# Spec to ensure wrapper cookbook can correctly override
# attributes using default level without _attributes
# recipe clearing them.

describe 'test::default' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '24.04', step_into: postfix_step_into).converge(described_recipe)
  end

  describe 'legacy wrapper attributes' do
    it 'keeps wrapper cookbook defaults when rendering main.cf' do
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(/^relayhost = please$/)
      expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(/^smtp_sasl_security_options = keep$/)
    end
  end
end
