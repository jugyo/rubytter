Gem::Specification.new do |s|
  s.name = 'rubytter'
  s.version = '0.2.1'
  s.summary = "Simple twitter client."
  s.description = "Rubytter is a simple twitter client."
  s.files = %w( lib/rubytter.rb
                lib/rubytter/connection.rb
                examples/friends_timeline.rb
                examples/update_status.rb
                spec/rubytter_spec.rb
                spec/spec_helper.rb
                README.rdoc
                History.txt )
  s.add_dependency("json", ">= 1.1.3")
  s.author = 'jugyo'
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://github.com/jugyo/rubytter'
  s.rubyforge_project = 'rubytter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
