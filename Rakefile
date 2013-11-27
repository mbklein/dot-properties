require "bundler/gem_tasks"
require 'rdoc/task'
require 'dot_properties/version'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern = FileList['./spec/**/*_spec.rb']
end
  
task :default => :spec

RDoc::Task.new do |rdoc|
  version = DotProperties::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dot-properties #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
