# Override a single master.cf service entry with a partial hash from a wrapper
# cookbook, as a user would do with force_default in their attributes.
node.force_default['postfix']['master']['bsmtp'] = { 'active' => false }

postfix 'default'
