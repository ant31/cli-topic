module Clitopic
  module Parser
    module Base
      def cmd_options
        @cmd_options ||= []
      end

      def option(name, *args, &blk)
        # args.sort.reverse gives -l, --long order
        cmd_options << { :name => name.to_s, :args => args, :proc => blk }
      end

      def options
        @options ||= {}
      end

    end
  end
end
