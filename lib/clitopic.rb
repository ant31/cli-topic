require 'clitopic/version'
require 'clitopic/parsers'

module Clitopic
  class << self
    attr_accessor :debug, :commands_dir, :parser, :default_parser, :version, :default_files, :load_defaults, :name
    def name
      @name ||= 'clito'
    end
    def parser
      @parser ||= default_parser
    end

    def load_defaults?
      @load_defaults ||= true
    end

    def parser=(name)
      Clitopic::Command::Base.extend name
      @parser = name
    end

    def default_parser
      @default_parsre ||= Clitopic::Parser::OptParser
    end
  end
end


# Defaults
Clitopic.name = "clitopic"
Clitopic.debug = false
Clitopic.version = Clitopic::VERSION
Clitopic.load_defaults = true
Clitopic.default_files = [File.join(Dir.getwd, ".clitopic.yml"), File.join(Dir.home, ".clitopic.yml")]


# Commaon Options

# Clitopic::Commands.global_option(:v, "--version", "-v", "Show version") {puts Clitopic.version}

Clitopic::Commands.global_option(:load_defaults, "--defaults-file FILE", "Load default variables") do |file|
  Clitopic::Commands.current_cmd.load_defaults(file)
end
