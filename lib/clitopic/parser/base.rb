module Clitopic
  module Parser
    module Base
      attr_accessor :arguments, :options
      def cmd_options
        @cmd_options ||= []
      end

      def option(name, *args, &blk)
        # args.sort.reverse gives -l, --long order
        default = nil
        required = false
        args.each do |a|
          if a.is_a?(Hash)
            if a.has_key?(:default)
              default = a[:default]
              options[name] = default
            end
            if a.has_key?(:required)
              required = a[:required]
            end
          end
        end

        cmd_options << { :name => name, :args => args, default: default, required: required, :proc => blk }
      end

      def options
        @options ||= {}
      end

    end
  end
end
