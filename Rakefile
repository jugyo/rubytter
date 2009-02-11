require "rake/gempackagetask"
require 'spec/rake/spectask'

desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end
