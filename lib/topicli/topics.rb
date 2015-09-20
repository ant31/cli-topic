module Topicli
  class TopicAlreadyExists  < ArgumentError; end

  class Topics
    class << self
      def []=(key, val)
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
