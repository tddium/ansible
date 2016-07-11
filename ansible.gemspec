require "./lib/ansible/version"

Gem::Specification.new do |s|
  s.name        = "ansible"
  s.version     = Ansible::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Solano Labs"]
  s.email       = ["info@solanolabs.com.com"]
  s.homepage    = "https://github.com/solanolabs/ansible.git/"
  s.summary     = %q{Fast ANSI->HTML conversion}
  s.description = <<-EOF
Ansible is a fast (somewhat rough) conversion tool that takes a string with ANSI
escapes and produces HTML.
EOF

  s.rubyforge_project = "tddium"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions    = ["ext/ansible/extconf.rb"]
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler")
  s.add_development_dependency("rspec")
  s.add_development_dependency("rake")
end
