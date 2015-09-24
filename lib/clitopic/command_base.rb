require 'ostruct'
require 'optparse'
require 'clitopic/topic_base'
module Clitopic
  module Command
    class Base
      class << self
        attr_accessor :name, :banner, :description, :short_description, :hidden

        def call(opts, args=[])
          puts "call with #{opts} #{args}"
        end

        def options
          @options ||= {}
        end

        def process_options(parser, opts)
          opts.each do |option|
            parser.on(*option[:args]) do |value|
              if option[:proc]
                option[:proc].call(value)
              end
              name = option[:name].gsub('-', '_').to_sym
              if options.has_key?(name) && options[name].is_a?(Array)
                options[name] += value
              else
                puts "Warning: already defined option: --#{option[:name]} #{options[name]}" if options.has_key?(name)
                options[name] = value
              end
            end
          end
          options
        end

        def parse(args)
          @opt_parser = OptionParser.new do |parser|
            # remove OptionParsers Officious['version'] to avoid conflicts
            # see: https://github.com/ruby/ruby/blob/trunk/lib/optparse.rb#L814
            parser.banner = self.banner unless self.banner.nil?
            parser.base.long.delete('version')
            process_options(parser, cmd_options)

            parser.separator ""
            parser.separator "Common options:"
            process_options(parser, Clitopic::Commands.global_options)

            # No argument, shows at tail.  This will print an options summary.
            # Try it and see!
            parser.on_tail("-h", "--help", "Show this message") do
              puts parser
              exit
            end
          end
          @opt_parser.parse!(args)
          @args = args
          return @options, @args
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

        def cmd_options
          @cmd_options ||= []
        end

        def option(name, *args, &blk)
          # args.sort.reverse gives -l, --long order
          cmd_options << { :name => name.to_s, :args => args.sort.reverse, :proc => blk }
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
