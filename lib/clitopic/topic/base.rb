require 'set'
require 'clitopic/topics'
require 'clitopic/utils'

module Clitopic
  module Topic
    class Base
      attr_accessor :name, :description, :short_description, :hidden, :banner

      def initialize(opts={}, force=false)
        opts = {hidden: false}.merge(opts)
        if !opts.has_key?(:name)
          raise ArgumentError.new("missing Topic name")
        end
        @description = opts[:description]
        @short_description = opts[:short_description]
        @name = opts[:name]
        @hidden = opts[:hidden]
        @banner = opts[:banner]
      end

      def commands
        @commands ||= {}
      end


      def short_description
        if @short_description.nil?
          if description
            @short_description = description.split("\n").first
          end
        end
        return @short_description
      end

      def name(arg=nil)
        @name ||= arg
      end

      def description(arg=nil)
        @description ||= arg
      end

      def hidden (arg=false)
        @hidden ||= arg
      end

      def topic_options
        self.class.topic_options
      end

      alias :hidden? :hidden

      private

      class << self
        attr_accessor :instance
        def option(name, *args, &blk)
          opt = Clitopic::Utils.parse_option(name, *args, &blk)
          if !opt[:default].nil?
            options[name] = opt[:default]
          end
          topic_options << opt
        end

        def topic_options
          @topic_options ||= []
        end

        def register(opts={}, force=false)
          topic = self.new(opts, force)
          if Topics.topics.has_key?(topic.name) && !force
            raise TopicAlreadyExists.new ("Topic: #{topic.name} already exists: #{Topics[topic.name].class.name}")
          else
            if self.class != Clitopic::Topic::Base
              @instance = topic
            end
            Topics[topic.name] = topic
          end
        end
      end
    end
  end
end
