module Clitopic
  module Command
    class Base
      class << self
        attr_accessor :name, :description, :short_description, :hidden
        def topic(arg)
          case arg
          when arg.is_a?(String)
            topic = Topics[arg]
          when arg < Clitopic::Topic::Base
            topic = arg
          when arg.is_a?(Hash)
            topic = Topics.create(args)
          end

        end
      end
    end
  end
end

module Image
  class Topic < Clitopic::Topic::Base
    register name: 'image', description: 'Manage docker images'
    topic_option '-a', '--all'
  end

  class Build < Clitopic::Command::Base
    topic 'image'
    register name: 'build', description: 'build docker images'
    # topic MyImageTopic
    # topic 'image', "description", false
    option "-a", "--all"
    #custom parse
    def parse_options(args)
    end

    def run(options, arguments)
      action
    end
  end

  class Push < Clitopic::Command::Base
    topic 'image'
    topic MyImageTopic
    topic 'image', "description", false
    option "-a", "--all"

    #custom parse
    def parse_options(args)
    end

    def call(options, arguments)
      action
    end
  end

end
