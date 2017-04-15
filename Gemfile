source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :unit_tests do
  gem 'rake', '10.5.0',                       :require => false
  gem 'rspec', '~> 2.0',                      :require => false
  gem 'rspec-puppet', '>= 2.1.0',             :require => false
  gem 'puppetlabs_spec_helper', '~> 1.2',     :require => false
  gem 'puppet-lint', '~> 2.0',                :require => false
  gem 'json', '~> 1.8',                       :require => false if RUBY_VERSION =~ /^1\./
  gem 'json',                                 :require => false if RUBY_VERSION =~ /^2\./
  gem 'json_pure', '~> 1.8',                  :require => false if RUBY_VERSION =~ /^1\.8/
  gem 'json_pure', '<= 2.0.1',                :require => false if RUBY_VERSION =~ /^1\.9/
  gem 'json_pure',                            :require => false if RUBY_VERSION =~ /^2\./
  gem 'metadata-json-lint', '>= 0.0.4',       :require => false
  gem 'semantic_puppet', '0.1.3',             :require => false if RUBY_VERSION =~ /^1\./
  gem 'semantic_puppet',                      :require => false if RUBY_VERSION =~ /^2\./
  gem 'puppet-lint-unquoted_string-check',    :require => false
  gem 'puppet-lint-empty_string-check',       :require => false
  gem 'puppet-lint-leading_zero-check',       :require => false
  gem 'puppet-lint-variable_contains_upcase', :require => false
end

gem 'puppet', ENV['PUPPET_GEM_VERSION'], :require => false
gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false

# vim:ft=ruby
