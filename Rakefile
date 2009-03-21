# -*- coding: utf-8 -*-
$:.unshift File.dirname(__FILE__) + '/lib/'
require 'rubytter'
require 'spec/rake/spectask'

desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end

desc 'Generate gemspec'
task :gemspec do |t|
  open('rubytter.gemspec', "wb" ) do |file|
    file << <<-EOS
Gem::Specification.new do |s|
  s.name = 'rubytter'
  s.version = '#{Rubytter::VERSION}'
  s.summary = "Simple twitter client."
  s.description = "Rubytter is a simple twitter client."
  s.files = %w( #{Dir['lib/**/*.rb'].join(' ')}
                #{Dir['spec/**/*.rb'].join(' ')}
                #{Dir['spec/**/*.json'].join(' ')}
                #{Dir['examples/**/*.rb'].join(' ')}
                README.rdoc
                History.txt
                Rakefile )
  s.add_dependency("json_pure", ">= 1.1.3")
  s.author = 'jugyo'
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://github.com/jugyo/rubytter'
  s.rubyforge_project = 'rubytter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
    EOS
  end
  puts "Generate gemspec"
end

desc 'Generate gem'
task :gem => :gemspec do |t|
  system 'gem', 'build', 'rubytter.gemspec'
end
