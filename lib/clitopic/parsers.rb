require 'clitopic/parser/base'
Dir[File.join(File.dirname(__FILE__), "parser", "*.rb")].each do |file|
  require file
end