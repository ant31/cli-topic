require 'clitopic/parsers'
require 'clitopic/topic'

module Clitopic
  module Command
    class Base
      class << self
        include Clitopic.parser

        attr_accessor :name, :banner, :description, :short_description, :hidden

        def call()
          puts "call with #{options} #{arguments}"
        end

        def load_defaults(file=nil)
          if file.nil?
            Clitopic.default_files.each do |f|
              if File.exist?(f)
                file = f
                break
              end
            end
          end
          if file.nil?
            return
          end

          defaults = YAML.load_file(file)
          if self.topic.nil?
            cmd_defaults = defaults[self.name]
          else
            cmd_defaults = defaults[self.topic.name][self.name]
          end
          cmd_defaults.each do |name, value|
            if !value.nil?
              if options[name].nil?
                options[name] = value
              elsif options[name].is_a?(Array)
                options[name] += value
              end
            end
          end
        end

        def topic(arg=nil)
          if !arg.nil?
            if arg.is_a?(String)
              @topic ||= Topics[arg]
            elsif arg.is_a?(Class) && arg < Clitopic::Topic::Base
              @topic ||= arg.instance
            elsif arg.is_a?(Hash)
              @topic ||= Clitopic::Topic::Base.register(arg)
            end
          end
          return @topic
        end


        def register(opts={})
          opts = {hidden: false}.merge(opts)
          if !opts.has_key?(:name)
            raise ArgumentError.new("missing Command name")
          end

          topic(opts[:topic])
          @description = opts[:description]
          @name = opts[:name]
          @hidden = opts[:hidden]
          @banner = opts[:banner]
          @short_description = opts[:short_description]

          if @topic.nil?
            Clitopic::Commands.global_commands[name] = self
          else
            topic.commands[name] = self
          end
        end
      end
    end
  end
end
