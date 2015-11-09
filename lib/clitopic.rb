require 'clitopic/version'
require 'clitopic/parsers'

module Clitopic
  class << self
    attr_accessor :debug, :commands_dir, :version, :default_files, :load_defaults, :name, :help_page, :issue_report
    def name
      @name ||= 'clito'
    end

    def load_defaults?
      @load_defaults
    end

  end
end


# Defaults
Clitopic.name = "clitopic"
Clitopic.debug = false
Clitopic.load_defaults = true
Clitopic.version = Clitopic::VERSION
Clitopic.default_files = [File.join(Dir.getwd, ".clitopic.yml"), File.join(Dir.home, ".clitopic.yml")]


# Commaon Options

# Clitopic::Commands.global_option(:v, "--version", "-v", "Show version") {puts Clitopic.version}

Clitopic::Commands.global_option(:load_defaults, "--defaults-file FILE", "Load default variables") do |file|
  Clitopic::Commands.current_cmd.load_defaults(file)
end
