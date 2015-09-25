require 'clitopic/command/base'

module Clitopic
  module Topic
    class Help < Clitopic::Topic::Base
      register name: "help", description: 'display helps'
    end
  end
  module Command

    class Help < Clitopic::Command::Base
      register name: 'index',
      description: "Display helps",
      banner: "Display helps",
      topic: "help"

      option :all, "--all", "Display all topics with all commands"
      option :topics, "--topics", "Display all availables topics"
      option :topic, "--topic=TOPIC", "Display availables commands for the TOPIC"
      option :with_hidden, "--with-hidden", "Include hidden commands/topics"
      class  << self

        def display_globals
          puts "# Commands"
          Clitopic::Commands.global_commands.each do |name, cmd|
            display_cmd(cmd)
          end
        end

        def display_cmd(cmd, topic=nil)
          if cmd.hidden == false || options[:with_hidden] == true
            if topic.nil?
              puts "----- #{cmd.name} -------"
            elsif cmd.name == 'index'
              puts "----- #{topic.name} -------"
            else
              puts "----- #{topic.name}:#{cmd.name} -------"
            end
            puts cmd.help
            puts "\n\n"
          end
        end

        def display_topic(topic_name)
          topic = Topics[topic_name]
          if topic.hidden == false || options[:with_hidden] == true
            puts "-- #{topic_name} \t\t #{topic.banner || topic.description}"
            topic.commands.each do |cmd_name, cmd|
              puts " + #{topic_name}:#{cmd_name} \t\t #{cmd.banner}"
            end
          end
        end

        def display_topics
          puts "# Topics"
          Clitopic::Topics.topics.each do |topic_name, topic|
            display_topic(topic_name)
          end
        end

        def display_all
          display_globals
          display_topics
        end

        def call
          if options[:all] == true
            display_all
          elsif options[:topics] == true
            display_topics
          elsif options.has_key?(:topic)
            display_topic(options[:topic])
          elsif arguments.size > 0
            cmd, topic = Clitopic::Commands.find_cmd(arguments[0])
            if cmd.nil?
              if Clitopic::Topics.topics[arguments[0]] != nil
                display_topic(arguments[0])
              else
                puts "Unknown command: #{arguments[0]}\n show all available commands with help --all"
              end
            else
              display_cmd(cmd, topic)
            end
          end

        end
      end
    end
  end
end
