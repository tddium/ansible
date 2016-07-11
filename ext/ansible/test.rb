$LOAD_PATH.unshift(".")

require 'ansible'

c = Ansible::Converter.new

["a", "b", "ab", "a\e[;1;31mmb"].each do |s|
  puts c.escape_to_html(s)
end

