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

      def check_required (opts)
        opts.each do |opt|
          if opt[:required] == true
            if options[opt[:name]].nil?
              message = "Missing required option: #{opt[:args][0]}"
              $stderr.puts(Clitopic::Helpers.format_with_bang(message) + "\n\n")
              Clitopic::Commands.run(self.fullname, ["--help"])
            end
          end
        end
      end

      def check_all_required
        check_required(self.cmd_options)
        check_required(self.topic.topic_options)
        check_required(Clitopic::Commands.global_options)
      end

      def parse(args)
        @invalid_options ||= []
        parser.parse!(args)
        check_all_required
        @arguments = args
        Clitopic::Commands.validate_arguments!(@invalid_options)
        return @options, @arguments
      rescue OptionParser::InvalidOption  => ex
        @invalid_options << ex.args.first
        retry
      end
    end
  end
end
