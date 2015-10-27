require 'yaml'
require 'clitopic/command/base'
require 'clitopic/helpers'

module Clitopic
  module Command
    class ClitoTopic < Clitopic::Topic::Base
      register name: 'clito',
        description: 'clitopic commands',
        hidden: true
    end

    class Suggestions < Clitopic::Command::Base
      register name: 'suggestions',
      description: 'suggests available commands base on incomplete input',
      hidden: true,
      topic: 'clito'

      def self.call
        puts Clitopic::Helpers.suggestion(@arguments[0], Clitopic::Commands.all_commands)
      end

    end

    class DefaultFile < Clitopic::Command::Base
      register name: 'defaults_file',
      description: "create default file",
      hidden: true,
      topic: 'clito'

      option :merge, "--[no-]merge", "Merge options with current file", default: true
      option :force, "-f", "--force", "Overwrite file", default: false


      class << self
        def cmd_opts(cmd, opts)
          if cmd.cmd_options.size > 0 && (!cmd.hidden || options[:hidden])
            opts[cmd.name] = {"options" => {}, "args" =>  []}
            cmd.cmd_options.each do |opt|
              opts[cmd.name]["options"][opt[:name].to_s] = opt[:default]
            end
          end
        end

        def dump_options(file, merge=true, force=false)
          opts = {"common_options" => {}}
          opts["common_options"] = {} if Clitopic::Commands.global_options.size > 0
          Clitopic::Commands.global_options.each do |opt|
            opts["common_options"][opt[:name].to_s] = opt[:default]
          end
          opts["commands"] = {} if Clitopic::Commands.global_commands.size > 0
          Clitopic::Commands.global_commands.each do |c, cmd|
            cmd_opts(cmd, opts["commands"])
          end
          Clitopic::Topics.topics.each do |topic_name, topic|
            if (!topic.hidden || options[:hidden])
              opts[topic_name] = {}
              opts[topic_name]["topic_options"] = {} if topic.topic_options.size > 0
              topic.topic_options.each do |opt|
                opts[topic_name]["topic_options"][opt[:name].to_s] = opt[:default]
              end
              if topic.commands.size > 0
                topic.commands.each do |c, cmd|
                  cmd_opts(cmd, opts[topic_name])
                end
              end
            end
          end

          if File.exist?(file)
            if merge == false && force == false
              raise ArgumentError.new("File #{file} exists, use --merge or --force")
            end
            if merge && !force
              return if not Clitopic::Helpers.confirm("Overwrite #{file} ? (y/N)")
              opts = opts.merge(YAML.load_file(file))
            end
          end
          puts "write: #{file}"
          File.open(file, 'wb') do  |file|
            file.write(opts.to_yaml)
          end
          puts opts.to_yaml
        end

        def call
          puts @options
          if @arguments.size == 0
            raise ArgumentError.new("Missing file")
          end
          file = @arguments[0]
          dump_options(file, @options[:merge], @options[:force])
        end
      end

    end

    class ClitoVersion < Clitopic::Command::Base
      register name: 'version',
      description: "Display clitopic version",
      hidden: true,
      topic: 'clito'

      class  << self
        def call
          puts "cli-topic version: #{Clitopic::VERSION}"
        end
      end
    end
  end
end
