require 'clitopic/topic/base'
Dir[File.join(File.dirname(__FILE__), "topic", "*.rb")].each do |file|
  require file
end
