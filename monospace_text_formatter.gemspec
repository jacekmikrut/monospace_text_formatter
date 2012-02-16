$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "monospace_text_formatter/version"

Gem::Specification.new do |s|
  s.name          = "monospace_text_formatter"
  s.version       = MonospaceTextFormatter::VERSION
  s.author        = "Jacek Mikrut"
  s.email         = "jacekmikrut.software@gmail.com"
  s.homepage      = "http://github.com/jacekmikrut/monospace_text_formatter"
  s.summary       = "Monospace text formatter."
  s.description   = "Monospace text formatter."

  s.files         = Dir["lib/**/*", "README*", "LICENSE*", "Changelog*"]
  s.require_path  = "lib"
end
