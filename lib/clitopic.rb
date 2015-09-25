require 'clitopic/parsers'
require 'clitopic/cli'

Clitopic.debug = false
Clitopic.default_parser = Clitopic::PARSERS[:optparse]
require 'clitopic/version'
require 'clitopic/utils'
require 'clitopic/commands'
require 'clitopic/command'
require 'clitopic/topics'
require 'clitopic/topic'

Clitopic.version = Clitopic::VERSION
Clitopic::Commands.global_option(:v, "--version", "-v", "Show version") {puts Clitopic.version}
Clitopic::Commands.global_option(:load_defaults, "--defaults-file FILE", "Load default variables") do |file|
  Clitopic::Commands.current_cmd.load_defaults(file)
end
Clitopic.load_defaults = true
Clitopic.default_files = [File.join(Dir.getwd, ".clitopic.yml"), File.join(Dir.home, ".clitopic.yml")]
