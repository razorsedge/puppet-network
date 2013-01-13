require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

desc "Run visual spec tests on an existing fixtures directory"
RSpec::Core::RakeTask.new(:spec_standalonev) do |t|
  t.rspec_opts = ['--color', '--format documentation']
  t.pattern = 'spec/{classes,defines,unit}/**/*_spec.rb'
end

