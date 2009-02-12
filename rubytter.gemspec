Gem::Specification.new do |s|
  s.name = 'rubytter'
  s.version = '0.2.0'
  s.summary = "Simple twitter client."
  s.description = "Rubytter is a simple twitter client."
  s.files = Dir["{lib}/**/*"].to_a +
            Dir["{examples}/**/*"].to_a +
            Dir["{spec}/**/*"].to_a +
            ["README.rdoc", "History.txt"]
  s.add_dependency("json", ">= 1.1.3")
  s.author = 'jugyo'
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://github.com/jugyo/rubytter'
  s.rubyforge_project = 'rubytter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
