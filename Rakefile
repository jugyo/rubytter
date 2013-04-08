require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rubytter"
    gem.summary = %Q{Simple twitter client.}
    gem.description = %Q{Rubytter is a simple twitter client.}
    gem.email = "jugyo.org@gmail.com"
    gem.homepage = "http://github.com/jugyo/rubytter"
    gem.rubyforge_project = "rubytter"
    gem.authors = ["jugyo"]
    gem.files = FileList['lib/**/*.rb', 'VERSION', 'README.rdoc', 'History.txt', 'Rakefile', 'spec/**/*.rb', 'spec/**/*.json', 'examples/**/*.rb']
    gem.add_dependency("json", ">= 1.1.3")
    gem.add_dependency("oauth", ">= 0.3.6")
    gem.add_development_dependency "rspec"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ['-c']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubytter #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
