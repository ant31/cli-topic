module Clitopic
  module Commands
    class CommandFailed  < RuntimeError; end

    module ClassMethods
      attr_accessor :binary, :current_cmd

      def command_aliases
        @@command_aliases ||= {}
      end

      def commands
        @@commands ||= {}
      end

      def current_args
        @current_args
      end

      def current_options
        @current_options ||= {}
      end

      def global_options
        @global_options ||= []
      end

      def global_option(name, *args, &blk)
        # args.sort.reverse gives -l, --long order
        global_options << { :name => name.to_s, :args => args.sort.reverse, :proc => blk }
      end

      def invalid_arguments
        @invalid_arguments
      end

      def shift_argument
        # dup argument to get a non-frozen string
        @invalid_arguments.shift.dup rescue nil
      end

      def validate_arguments!
        unless invalid_arguments.empty?
          arguments = invalid_arguments.map {|arg| "\"#{arg}\""}
          if arguments.length == 1
            message = "Invalid argument: #{arguments.first}"
          elsif arguments.length > 1
            message = "Invalid arguments: "
            message << arguments[0...-1].join(", ")
            message << " and "
            message << arguments[-1]
          end
          $stderr.puts(format_with_bang(message))
          run(current_command, ["--help"])
          exit(1)
        end
      end

      def get_cmd(cmd)
        commands[cmd] || commands[command_aliases[cmd]]
      end

      def run(cmd, arguments=[])
        klass = prepare_run(cmd, arguments.dup)
        klass.call(arguments)
      end

      def prepare_run(cmd, args=[])
        puts cmd, args
        command = get_cmd(cmd)
        puts command
      end
    end
    class << self
      include ClassMethods
#      global_option :help,    "-h", "--help"
    end
  end
end
