require 'yaml'
require 'clitopic/utils'
require 'clitopic/parsers'
require 'clitopic/topic'

module Clitopic
  module Command
    class Base
      class << self
        include Clitopic::Parser::OptParser
        attr_accessor :name, :banner, :description, :hidden, :short_description
        attr_accessor :arguments, :options

        def cmd_options
          @cmd_options ||= []
        end

        def banner
          @banner ||= "Usage: #{Clitopic.name} #{self.fullname} [options]"
        end

        def short_description
          if @short_description.nil?
            if description
              @short_description = description.split("\n").first
            end
          end
          return @short_description
        end

        def option(name, *args, &blk)
          opt = Clitopic::Utils.parse_option(name, *args, &blk)
          if !opt[:default].nil?
            options[name] = opt[:default]
          end
          cmd_options << opt
        end

        def fullname
          if topic.nil?
            return name
          elsif name == 'index'
            "#{topic.name}"
          else
            "#{topic.name}:#{name}"
          end
        end

        def call()
          puts "call with #{options} #{arguments}"
        end

        def arguments
          @arguments ||= []
        end

        def topic_options
          if !self.topic.nil?
            @topic_options ||= self.topic.class.options
          else
            @topic_options = {}
          end
        end

        def options
          @options ||= topic_options.dup
        end

        def load_options(opts)
          return if opts.nil?
          opts.each do |name, value|
            name = name.to_s.to_sym
            if !value.nil?
              if options[name].is_a?(Array)
                options[name] += value
              else
                options[name] = value
              end
            end
          end
        end

        def load_defaults(file=nil)
          file ||= Clitopic::Helpers.find_default_file
          if file.nil?
            return
          end

          begin
            defaults = YAML.load_file(file)
          rescue
            puts "failed to load defaults file: #{file}"
            return
          end

          if self.topic.nil?
            if defaults.has_key?("commands")
              cmd_defaults = defaults["commands"][self.name]
            end
          else
            if defaults.has_key?("topics") && defaults["topics"].has_key?(self.topic.name)
              cmd_defaults = defaults['topics'][self.topic.name][self.name]
              topic_opts = defaults['topics'][self.topic.name]['topic_options']
            end
          end

          load_options(topic_opts)

          if cmd_defaults.nil?
            return
          end

          load_options(cmd_defaults["options"])
          if cmd_defaults["args"] && !arguments
            @arguments += Array(cmd_defaults["args"])
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
