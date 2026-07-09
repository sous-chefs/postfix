require 'chefspec'
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
end

def postfix_step_into
  %i(postfix postfix_config postfix_install postfix_map postfix_sasl_auth postfix_server postfix_service)
end
