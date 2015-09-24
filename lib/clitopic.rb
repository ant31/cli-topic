require 'clitopic/parsers'
require 'clitopic/cli'

Clitopic.debug = false
Clitopic.default_parser = Clitopic::PARSERS[:optparse]

require 'clitopic/version'
require 'clitopic/utils'
require 'clitopic/commands'
require 'clitopic/command_base'
require 'clitopic/topics'
require 'clitopic/topic_base'

Clitopic::Commands.global_option(:v, "--version", "-v", "Show version") {puts Clitopic::VERSION}
Clitopic::Commands.global_option(:array, "--array x,y,z", Array, "get Array")
