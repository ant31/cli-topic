require 'clitopic/command/base'

module Clitopic
  module Topic
    class Help < Clitopic::Topic::Base
      register name: "help", description: "topic description"
    end
  end

  module Command
    class Help2 < Clitopic::Command::Base
      register name: 'help2',
      description: "Display helps",
      banner: "Display helps",
      topic: "help"

      option :all, "--all", "Display all topics with all commands"
      option :topics, "--topics", "Display all availables topics"
      option :topic, "--topic=TOPIC", "Display availables commands for the TOPIC"
      option :with_hidden, "--with-hidden", "Include hidden commands/topics"
    end

    class Help < Clitopic::Command::Base
      register name: 'index',
      banner: "Usage: #{Clitopic.name} help [COMMAND]",
      description: "list available commands or display help for a specific command",
      topic: "help"

      option :all, "--all", "Display all topics with all commands"
      option :topics, "--topics", "Display all availables topics"
      option :topic, "--topic=TOPIC", "Display availables commands for the TOPIC"
      option :with_hidden, "--with-hidden", "Include hidden commands/topics"
      class  << self


        def header(obj)
          puts obj.description
          puts "\n"
        end

        def display_globals
          puts "Primary help topics, type \"#{Clitopic.name} help TOPIC\" for more details:\n\n"
          Clitopic::Commands.global_commands.each do |name, cmd|
            puts ("%-#{longest_global_cmd + 3}s  # %s" % [ "#{name}", "#{cmd.short_description}"]).indent(2)
          end
        end

        def display_cmd(cmd, with_header=false)
          if with_header
            header(cmd)
          end
          if cmd.hidden == false || options[:with_hidden] == true
            puts cmd.help
            puts "\n\n"
          end
        end

        def longest_global_cmd
          @longest_global_cmd ||= Clitopic::Commands.global_commands.keys.map{|k| k.size}.max
        end

        def longest_cmd
          @longest_cmd ||= Clitopic::Commands.all_commands.map{|k| k.size}.max
        end

        def longest_topic
          @longest_topic ||= Topics.topics.keys.map{|k| k.size}.max
        end

        def display_topic(topic_name, with_commands=false, with_header=false)
          if with_commands
            longest = longest_cmd
          else
            longest = longest_topic
          end
          topic = Topics[topic_name]
          if with_header
            header(topic)
          end
          if topic.hidden == false || options[:with_hidden] == true
            if with_header
              if !topic.commands['index'].nil?
                display_cmd(topic.commands['index'])
              end
            else
              puts ("%-#{longest + 3}s  # %s" % [ "#{topic_name}", "#{topic.short_description}" ]).indent(2)
            end
            if with_commands
              puts "Additional commands, type \"#{Clitopic.name} help COMMAND\" for more details:\n\n" if with_header
              topic.commands.each do |cmd_name, cmd|
                puts ("   %-#{longest}s  # %s" % [ "#{cmd.fullname}", "#{cmd.short_description}"]).indent(2)
              end
              puts ""
            end
          end
        end

        def display_topic_help(topic_name)
          topic = Topics[topic_name]
          longest = topic.commands.keys.map{|a| "#{topic_name}:#{a}".size}.max
          header(topic)

          if topic.hidden == false || options[:with_hidden] == true
            if !topic.commands['index'].nil?
              display_cmd(topic.commands['index'], true)
            end
            puts "Additional commands, type \"#{Clitopic.name} help COMMAND\" for more details:\n\n"
            topic.commands.each do |cmd_name, cmd|
              puts ("%-#{longest}s  # %s" % [ "#{cmd.fullname}", "#{cmd.short_description}"]).indent(2)
            end
          end
        end

        def display_topics(with_commands=false)
          puts "Additional topics:\n\n"
          Clitopic::Topics.topics.each do |topic_name, topic|
            display_topic(topic_name, with_commands)
          end
        end

        def display_all(with_commands=false)
          puts "Usage: #{Clitopic.name} COMMAND [command-specific-options]\n\n"

          header(self)
          display_globals
          puts "\n"
          display_topics(with_commands)
        end

        def call
          if options[:all] == true
            display_all(true)
          elsif options.has_key?(:topic)
            display_topic_help(options[:topic])
          elsif arguments.size > 0
            if Clitopic::Topics.topics[arguments[0]] != nil
              display_topic_help(arguments[0])
            else
              cmd, topic = Clitopic::Commands.find_cmd(arguments[0])
              if cmd.nil?
                puts "Unknown command: #{arguments[0]}\n show all available commands with help --all"
              else
                display_cmd(cmd, true)
              end
            end
          else
            display_all
          end
        end
      end
    end
  end
end
