source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :unit_tests do
  gem 'rake', '< 11.0',                       :require => false
  gem 'rspec', '~> 2.0',                      :require => false
  gem 'rspec-puppet', '>= 2.1.0',             :require => false
  gem 'puppetlabs_spec_helper',               :require => false
  gem 'puppet-lint', '>= 1.1.0',              :require => false
  gem 'simplecov',                            :require => false
  gem 'puppet_facts',                         :require => false
  gem 'json', ENV['JSON_VERSION'],            :require => false
  gem 'json_pure', ENV['JSON_VERSION'],       :require => false
  gem 'metadata-json-lint', '>= 0.0.4',       :require => false
  gem 'puppet-lint-unquoted_string-check',    :require => false
  gem 'puppet-lint-empty_string-check',       :require => false
  gem 'puppet-lint-leading_zero-check',       :require => false
  gem 'puppet-lint-variable_contains_upcase', :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
