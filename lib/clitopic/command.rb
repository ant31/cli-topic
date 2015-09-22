module Clitopic
  module Commands
    class CommandFailed  < RuntimeError; end

    module ClassMethod
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

      def load(dir)
        Dir[dir, "*.rb")].each do |file|

        require file
      end
    end

    def run

      end

    end

    class << self
      include ClassMethods
    end
  end
end
