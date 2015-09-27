module Clitopic
  module Parser
    module Dummy

      def help
        puts parse
      end

      def parse(args)
        puts "i'm parsing #{args}"
      end

    end
  end
end
