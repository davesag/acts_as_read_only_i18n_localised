# rubocop:disable all
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => [:spec]
rescue LoadError
  # ignore
end
# rubocop:enable all
