require 'clitopic/utils'
require 'clitopic/topics'

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
        global_options << Clitopic::Utils.parse_option(name, *args, &blk)
      end

      def invalid_arguments
        @invalid_arguments
      end

      def shift_argument
        # dup argument to get a non-frozen string
        @invalid_arguments.shift.dup rescue nil
      end

      def validate_arguments!(invalid_options)
        unless invalid_options.empty?
          arguments = invalid_options.map {|arg| "\"#{arg}\""}
          if arguments.length == 1
            message = "Invalid option: #{arguments.first}"
          elsif arguments.length > 1
            message = "Invalid options: "
            message << arguments[0...-1].join(", ")
            message << " and "
            message << arguments[-1]
          end
          $stderr.puts(Clitopic::Helpers.format_with_bang(message) + "\n\n")
          run(@current_cmd.fullname, ["--help"])
        end
      end

      def all_commands
        cmds = []
        Topics.topics.each do |k,topic|
          topic.commands.each do |name, cmd|
            if name == 'index'
              cmds << topic.name
            else
              cmds << "#{topic.name}:#{name}"
            end
          end
        end
        cmds += global_commands.keys
        return cmds
      end

      def prepare_run(cmd, arguments)
        @current_options, @current_args = cmd.parse(arguments.dup)
      rescue OptionParser::ParseError => e
        $stderr.puts Clitopic::Helpers.format_with_bang(e.message)
        run("help", [cmd.fullname])
      end

      def run(cmd, arguments=[])
        if cmd == "-h" || cmd == "--help"
          cmd = 'help'
        end
        @current_cmd, @current_topic = find_cmd(cmd)
        if !@current_cmd
          Clitopic::Helpers.error([ "`#{cmd}` is not a command.",
                                    Clitopic::Helpers.display_suggestion(cmd, all_commands),
                                    "See `help` for a list of available commands."
                                  ].compact.join("\n\n"))
        end
        prepare_run(@current_cmd, arguments)
        if @current_cmd.options[:load_defaults] == true || Clitopic.load_defaults?
          puts 'load'
          @current_cmd.load_defaults
        end
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
          return nil, nil
        end
        return current_cmd, current_topic
      end
    end

    class << self
      include ClassMethods
    end
  end

end
