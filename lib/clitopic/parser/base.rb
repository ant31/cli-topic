require 'clitopic/utils'

module Clitopic
  module Parser
    module Base
      attr_accessor :arguments, :options
      def cmd_options
        @cmd_options ||= []
      end

      def option(name, *args, &blk)
        opt = Clitopic::Utils.parse_option(name, *args, &blk)
        if !opt[:default].nil?
          options[name] = opt[:default]
        end
        cmd_options << opt
      end

      def options
        @options ||= {}
      end

    end
  end
end
