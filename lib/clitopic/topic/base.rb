require 'set'
require 'clitopic/topics'

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
        @name = opts[:name]
        @hidden = opts[:hidden]
        @banner = opts[:banner]
      end

      def commands
        @commands ||= {}
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

      alias :hidden? :hidden

      private

      class << self
        attr_accessor :instance
        def register(opts={}, force=false)
          topic = self.new(opts, force)
          if Topics[topic.name].nil? && force
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
