require 'set'
require 'clitopic/topics'

module Clitopic
  module Topic
    class Base
      class << self
        attr_accessor :name, :description, :hidden

        def commands
          @commands ||= Set.new
        end

        def name(arg=nil)
          @name ||= arg
        end

        def description (arg=nil)
          @description ||= arg
        end

        def hidden (arg=false)
          @hidden ||= arg
        end

        alias :hidden? :hidden


      def register(name: , description:, hidden: false, force: false)
        @description = description
        @name = name
        @hidden = hidden
        topic = self
        if !Topics[name].nil? && !force
          raise TopicAlreadyExists.new ("Topic: #{topic.name} already exists: #{Topics[name].name}")
        else
          Topics[name] = topic
        end
      end

      end
    end
  end
end
