require 'set'
require 'topicli/topics'

module Topicli
  module Topic
    class Base
      class << self
        attr_accessor :description, :hidden

        def commands
          @commands ||= Set.new
        end

        def description (arg=nil)
          @description ||= arg
        end

        def hidden (arg=false)
          @hidden ||= arg
        end

        alias :hidden? :hidden

      protected

      def register(name: , description:, hidden: false, force: false)
        topic = self
        if topics.has_key?(name) && !force
          raise TopicAlreadyExists.new ("Topic: #{topic.name} already exists: #{topics[name].name}")
        else
          Topics[name] = topic
        end
      end

      end
    end
  end
end
