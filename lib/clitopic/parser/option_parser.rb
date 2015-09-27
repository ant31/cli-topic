require 'optparse'
require 'clitopic/commands'

module Clitopic
  module Parser
    module OptParser
      def process_options(parser, opts)
        opts.each do |option|
          parser.on(*option[:args]) do |value|
            if option[:proc]
              option[:proc].call(value)
            end
            name = option[:name]
            if options.has_key?(name) && options[name].is_a?(Array)
              options[name] += value
            else
              puts "Warning: already defined option: --#{option[:name]} #{options[name]}" if options.has_key?(name) && option[:default] == nil
              options[name] = value
            end
            end
        end
        options
      end

      def parser
        @opt_parser = OptionParser.new do |parser|
          # remove OptionParsers Officious['version'] to avoid conflicts
          # see: https://github.com/ruby/ruby/blob/trunk/lib/optparse.rb#L814
          parser.banner = self.banner unless self.banner.nil?
          parser.base.long.delete('version')
          process_options(parser, self.cmd_options)

          if !self.topic.nil? && self.topic.topic_options.size > 0
            parser.separator ""
            parser.separator "Topic options:"
            process_options(parser, self.topic.topic_options)
          end

          parser.separator ""
          parser.separator "Common options:"
          process_options(parser, Clitopic::Commands.global_options)

          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          parser.on_tail("-h", "--help", "Show this message") do
            puts parser
            exit 0
          end
        end
        return @opt_parser
      end

      def help
        parser.to_s
      end

      def parse(args)
        parser.parse!(args)
        @arguments = args
        return @options, @arguments
      end

    end
  end
end
