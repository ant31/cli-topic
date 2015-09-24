require 'clitopic/parsers'
require 'clitopic/commands'
module Clitopic
  PARSERS = {optparse: Clitopic::Parser::OptParser, dummy: Clitopic::Parser::Dummy}
  class << self
    attr_accessor :debug, :commands_dir, :parser, :default_parser, :version

    def parser
      @parser ||= default_parser
    end

    def parser=(name)
      Clitopic::Command::Base.extend name
      @parser = name
    end

    def run(args)
      $stdin.sync = true if $stdin.isatty
      $stdout.sync = true if $stdout.isatty
      command = args.shift.strip rescue "help"
      if !commands_dir.nil?
        Clitopic::Commands.load(Clitopic.commands_dir)
      end
      Clitopic::Commands.run(command, args)
    rescue Errno::EPIPE => e
      puts e.message #error(e.message)
      puts e.backtrace
    rescue Interrupt => e
      `stty icanon echo`
      if Clitopic.debug
        puts e.message #        styled_error(e)
        puts e.backtrace
      else
        puts e #.message error("Command cancelled.", false)
      end
    rescue => error
      puts error.message # styled_error(error)
      puts error.backtrace
      #      exit(1)
    end
  end

end
