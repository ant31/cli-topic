module Clitopic
  module Commands
    class CommandFailed  < RuntimeError; end

    module ClassMethods
      attr_accessor :binary, :current_cmd, :current_topic

      def load_commands(dir)
        Dir[File.join(dir, "*.rb")].each do |file|
          require file
        end
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

      def global_commands
        @global_commands ||= {}
      end

      def global_option(name, *args, &blk)
        # args.sort.reverse gives -l, --long order
        global_options << { :name => name.to_s, :args => args, :proc => blk }
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
          # exit(1)
        end
      end

      def run(cmd, arguments=[])
        @current_cmd, @current_topic = find_cmd(cmd)
        @current_options, @current_args = current_cmd.parse(arguments.dup)
        @current_cmd.call
      end

      def find_cmd(command)
        cmd_name, sub_cmd_name = command.split(':')
        if global_commands.has_key?(command)
          current_cmd = global_commands[cmd_name]
        elsif !Topics[cmd_name].nil?
          sub_cmd_name = 'index' if sub_cmd_name.nil?
          current_topic = Topics[cmd_name]
          current_cmd = current_topic.commands[sub_cmd_name]
        else
          current_cmd = global_commands[:help]
        end
        return current_cmd, current_topic
      end
    end

    class << self
      include ClassMethods
    end
  end

end
