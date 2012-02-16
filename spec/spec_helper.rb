require "rubygems"
require "bundler/setup"

require "monospace_text_formatter"

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |file| require file }

RSpec.configure do |config|
end
