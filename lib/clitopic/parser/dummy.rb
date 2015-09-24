module Clitopic
  module Parser
    module Dummy
      include Clitopic::Parser::Base

      def process_options(parser, opts)

      end

      def parse(args)
        puts "i'm parsing #{args}"
      end

    end
  end
end
