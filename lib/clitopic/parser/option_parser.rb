require 'optparse'
module Clitopic
  module Parser
    module OptParser
      include Clitopic::Parser::Base

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

      def parser
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
          end
        end
        return @opt_parser
      end

      def help
        parser.to_s
      end

      def parse(args)
        parser.parse!(args)
        @args = args
        return @options, @args
      end

    end
  end
end
