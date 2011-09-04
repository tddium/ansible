$:.push File.expand_path("../lib", __FILE__)
require "ansible/version"

Gem::Specification.new do |s|
  s.name        = "ansible"
  s.version     = AnsibleVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Solano Labs"]
  s.email       = ["info@tddium.com"]
  s.homepage    = "http://www.tddium.com/"
  s.summary     = %q{Fast ANSI->HTML conversion}
  s.description = <<-EOF
Ansible is a fast (somewhat rough) conversion tool that takes a string with ANSI
escapes and produces HTML.
EOF

  s.rubyforge_project = "tddium"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler")
  s.add_development_dependency("rspec")
  s.add_development_dependency("rake")
end
