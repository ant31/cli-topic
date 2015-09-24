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
