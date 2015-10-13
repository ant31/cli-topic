class String
  def indent!(amount, indent_string=nil, indent_empty_lines=false)
    indent_string = indent_string || self[/^[ \t]/] || ' '
    re = indent_empty_lines ? /^/ : /^(?!$)/
    gsub!(re, indent_string * amount)
  end

  def indent(amount, indent_string=nil, indent_empty_lines=false)
    dup.tap {|_| _.indent!(amount, indent_string, indent_empty_lines)}
  end

  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

module Clitopic
  module Utils
    class << self
      def has_git?
        %x{ git --version }
        $?.success?
      end

      def git(args)
        return "" unless has_git?
        flattened_args = [args].flatten.compact.join(" ")
        %x{ git #{flattened_args} 2>&1 }.strip
      end

      def retry_on_exception(*exceptions)
        retry_count = 0
        begin
          yield
        rescue *exceptions => ex
          raise ex if retry_count >= 3
          sleep 3
          retry_count += 1
          retry
        end
      end

      def parse_option(name, *arguments, &blk)
        # args.sort.reverse gives -l, --long order
        default = nil
        required = false
        args = []
        arguments.each do |a|
          if a.is_a?(Hash)
            if a.has_key?(:default)
              default = a[:default]
              a.delete(:default)
            end
            if a.has_key?(:required)
              required = a[:required]
              a.delete(:required)
            end
          else
            args << a
          end
        end
        return { :name => name, :args => args, default: default, required: required, :proc => blk }
      end
    end
  end
end
