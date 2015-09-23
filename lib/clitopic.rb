require 'clitopic/cli'
require 'clitopic/version'
require 'clitopic/utils'
require 'clitopic/commands'
require 'clitopic/command_base'
require 'clitopic/topics'
require 'clitopic/topic_base'

Clitopic.debug = false

Clitopic::Commands.global_option(:v, "--version", "-v", "Show version") {puts Clitopic::VERSION}
Clitopic::Commands.global_option(:array, "--array x,y,z", Array, "get Array")
