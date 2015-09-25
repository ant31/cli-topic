require 'yaml'
require 'clitopic/command/base'

module Clitopic
  module Command
    class DefaultFile < Clitopic::Command::Base
      register name: 'defaults_file',
      description: "create default file",
      hidden: true,
      topic: {name: 'clito', description: 'clitopic commands', hidden: true}

      option :merge, "--[no-]merge", "Merge options with current file", default: true
      option :force, "-f", "--force", "Overwrite file", default: false

      class << self
        def cmd_opts(cmd, opts)
          if cmd.cmd_options.size > 0
            opts[cmd.name] = {}
            cmd.cmd_options.each do |opt|
              opts[cmd.name][opt[:name]] = opt[:default]
            end
          end
        end

        def dump_options(file, merge=true, force=false)
          opts = {}
          Clitopic::Commands.global_commands.each do |c, cmd|
            cmd_opts(cmd, opts)
          end
          Clitopic::Topics.topics.each do |topic_name, topic|
            if topic.commands.size > 0
              opts[topic_name] = {}
              topic.commands.each do |c, cmd|
                cmd_opts(cmd, opts[topic_name])
              end
            end
          end

          if File.exist?(file)
            if merge == false && force == false
              raise ArgumentError.new("File #{file} exists, use --merge or --force")
            end
            if merge && !force
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
  end
end
