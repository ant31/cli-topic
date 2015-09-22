
module Clitopic
  class TopicAlreadyExists  < ArgumentError; end

  class Topics
    class << self
      require 'clitopic/topic_base'
      def []=(key, val)
        if not (val.is_a?(Clitopic::Topic::Base))
          raise ArgumentError.new("#{val} is not a Topic")
        end
        topics[key] = val
      end

      def [](key)
        topics[key]
      end

      def to_s
        topics.to_s
      end

      def topics
        @@topics ||= {}
      end
    end
  end
end
