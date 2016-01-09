require 'yaml'
require 'clitopic/command/base'
require 'clitopic/helpers'

module Clitopic
  module Command
    class ClitoTopic < Clitopic::Topic::Base
      register name: 'clitopic',
        description: 'clitopic commands',
        hidden: false
    end

    class Suggestions < Clitopic::Command::Base
      register name: 'suggestions',
      description: 'suggests available commands base on incomplete input',
      hidden: true,
      topic: 'clitopic'

      def self.call
        puts Clitopic::Helpers.suggestion(@arguments[0], Clitopic::Commands.all_commands)
      end

    end

    class DefaultsFile < Clitopic::Command::Base
      register name: 'create-defaults',
      description: "create default file",
      hidden: false,
      topic: 'clitopic'

      option :merge, "--[no-]merge", "Merge options with current file", default: true
      option :force, "-f", "--force", "Overwrite file", default: false
      option :topics, "-t", "--topics TOPICS", Array,  "create file for TOPICS list only"

      class << self
        def cmd_opts(cmd, opts)
          if cmd.cmd_options.size > 0 && (!cmd.hidden || options[:hidden])
            cmd_comment = "#{cmd.name}$comment"
            opts[cmd_comment] = {}
            opts = opts[cmd_comment]
            opts[cmd.name] = {"options" => {}, "args" =>  []}
            cmd.cmd_options.each do |opt|
              opts[cmd.name]["options"]["#{opt[:name].to_s}$comment"] = {}
              opts[cmd.name]["options"]["#{opt[:name].to_s}$comment"][opt[:name].to_s] = opt[:default]
            end
          end
        end

        def deep_merge(h1, h2)
          merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
          h1.merge(h2, &merger)
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
          opts['topics'] = {}
          Clitopic::Topics.topics.each do |topic_name, topic|
            if @options[:topics] && !@options[:topics].index(topic_name.to_s)
              next
            end

            if (!topic.hidden || options[:hidden])
              topic_comment = "#{topic_name}$comment"
              opts['topics'][topic_comment] = {}
              opts['topics'][topic_comment][topic_name] = {}
              opts['topics'][topic_comment][topic_name]["topic_options$comment"] = {"topic_options" => {}} if topic.topic_options.size > 0
              topic.topic_options.each do |opt|
                opts['topics'][topic_comment][topic_name]["topic_options$comment"]["topic_options"][opt[:name].to_s] = opt[:default]
              end
              if topic.commands.size > 0
                topic.commands.each do |c, cmd|
                  cmd_opts(cmd, opts['topics'][topic_comment][topic_name])
                end
              end
            end
          end

          if File.exist?(file)
            if merge == false && force == false
              raise ArgumentError.new("File #{file} exists, use --merge or --force")
            end
            if merge && !force
              opts = deep_merge(opts, YAML.load_file(file))
            end
          end
          puts "write: #{file}"
          yaml = opts.to_yaml
          yaml = yaml.gsub("topic_options$comment:", "  # common-topic options")
          Clitopic::Topics.topics.each do |topic_name, topic|
            yaml = yaml.gsub(/(\s+)#{topic_name}\$comment:/, '\1' + topic_comment(topic))
            if topic.commands.size > 0
              topic.commands.each do |c, cmd|
                yaml = yaml.gsub(/(\s+)#{c}\$comment:/, '\1' + cmd_comment(cmd))
                yaml = opt_comment(cmd, yaml)
              end
            end
          end
          File.open(file, 'wb') do  |file|
            file.write(yaml)
          end
          return opts
        end

        def topic_comment(topic)
          "\n    # Topic: #{topic.name}\n" +
          "    # #{topic.description.gsub("\n", "\n    # ")}"
        end

        def cmd_comment(cmd)
          "\n        # #{cmd.fullname}\n" +
          "        # #{cmd.short_description}"
        end

        def opt_comment(cmd, yaml)
          if cmd.cmd_options.size > 0 && (!cmd.hidden || options[:hidden])
            cmd.cmd_options.each do |opt|
              yaml = yaml.gsub(/(\s+)#{opt[:name].to_s}\$comment:/, '\1' +  "# #{opt[:args].last}")
            end
          end
          return yaml
        end

        def call
          if @arguments.size == 0
            file = Clitopic::Helpers.find_default_file || Clitopic.default_files.first
            if file.nil?
              raise ArgumentError.new("Missing file")
            end
          else
            file = @arguments[0]
          end
          opts = dump_options(file, @options[:merge], @options[:force])
          puts opts
          return opts
        end
      end

    end

    class ClitoVersion < Clitopic::Command::Base
      register name: 'version',
      description: "Display clitopic version",
      hidden: true,
      topic: 'clitopic'

      class  << self
        def call
          puts "cli-topic version: #{Clitopic::VERSION}"
        end
      end
    end
  end
end
