require 'clitopic/parsers'
require 'clitopic/topic_base'

module Clitopic
  module Command
    class Base
      class << self
        include Clitopic.parser

        attr_accessor :name, :banner, :description, :short_description, :hidden

        def call(opts, args=[])
          puts "call with #{opts} #{args}"
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

class ImagePush < Clitopic::Command::Base
  register name: 'push',
  description: "descrption1",
  banner: "banner1",
  topic: {name: "image", description: "titi"}
end
# module Image
#   class Topic < Clitopic::Topic::Base
#     register name: 'image', description: 'Manage docker images'
#     topic_option '-a', '--all'
#   end

#   class Build < Clitopic::Command::Base
#     topic 'image'
#     register name: 'build', description: 'build docker images'
#     # topic MyImageTopic
#     # topic 'image', "description", false
#     option "-a", "--all"
#     #custom parse
#     def parse_options(args)
#     end

#     def run(options, arguments)
#       action
#     end
#   end

#   class Push < Clitopic::Command::Base
#     topic 'image'
#     topic MyImageTopic
#     topic 'image', "description", false
#     option "-a", "--all"

#     #custom parse
#     def parse_options(args)
#     end

#     def call(options, arguments)
#       action
#     end
#   end

# end
