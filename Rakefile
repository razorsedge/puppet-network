require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

desc "Run visual spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_standalonev) do |t|
  t.rspec_opts = ['--color', '--format documentation']
  t.pattern = 'spec/{classes,defines,unit}/**/*_spec.rb'
end

# https://github.com/stahnma/puppet-modules/blob/master/common/Rakefile
desc "Run puppet in noop mode and check for syntax errors."
task :validate do
  Dir['manifests/**/*.pp'].each do |path|
    sh "puppet parser validate --noop #{path}"
  end
end

# Enable puppet-lint for all manifests: rake lint
require 'puppet-lint/tasks/puppet-lint'
#PuppetLint.configuration.send("disable_80chars") # no warnings on lines over 80 chars.
PuppetLint.configuration.ignore_paths = ["spec/fixtures/**/*.pp", "pkg/**/*"]

