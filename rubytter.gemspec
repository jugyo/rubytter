# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "rubytter/version"

Gem::Specification.new do |s|
  s.name        = "rubytter"
  s.version     = Rubytter::VERSION
  s.summary     = %Q{Simple twitter client.}
  s.description = %Q{Rubytter is a simple twitter client.}
  s.email       = "jugyo.org@gmail.com"
  s.homepage    = "http://github.com/jugyo/rubytter"
  s.authors     = ["jugyo"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "json", ">= 1.1.3"
  s.add_dependency "oauth", ">= 0.3.6"
  s.add_development_dependency "rspec", "~> 1.0"
  s.add_development_dependency "rake"
end
