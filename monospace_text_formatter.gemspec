$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "monospace_text_formatter/version"

Gem::Specification.new do |s|
  s.name          = "monospace_text_formatter"
  s.version       = MonospaceTextFormatter::VERSION
  s.author        = "Jacek Mikrut"
  s.email         = "jacekmikrut.software@gmail.com"
  s.homepage      = "http://github.com/jacekmikrut/monospace_text_formatter"
  s.summary       = "Formats monospaced text into a line or visual box."
  s.description   = "Formats monospaced text into a line or visual box of defined 'width' and 'height' boundaries (expressed in number of characters)."

  s.files         = Dir["lib/**/*", "README*", "LICENSE*", "Changelog*"]
  s.require_path  = "lib"

  s.add_development_dependency "rspec", "~> 2.0"
end
