require 'clitopic/commands'
require 'clitopic/command'
require 'clitopic/helpers'
module Clitopic
  module Cli

    class << self

      def run(args)
        args = args.dup
        $stdin.sync = true if $stdin.isatty
        $stdout.sync = true if $stdout.isatty
        command = args.shift.strip rescue "help"
        if !Clitopic.commands_dir.nil?
          Clitopic::Commands.load_commands(Clitopic.commands_dir)
        end
        Clitopic::Commands.run(command, args)
      rescue Errno::EPIPE => e
        puts e.message #error(e.message)
        puts e.backtrace
      rescue Interrupt => e
        `stty icanon echo`
        if Clitopic.debug
          Clitopic::Helpers.styled_error(e)
        else
          Clitopic::Helpers.error("Command cancelled.", false)
        end
      rescue => error
        Clitopic::Helpers.styled_error(error)
        exit(1)
      end
    end
  end
end
