class String
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
      def parse_option(name, *args, &blk)
        # args.sort.reverse gives -l, --long order
        default = nil
        required = false
        args.each do |a|
          if a.is_a?(Hash)
            if a.has_key?(:default)
              default = a[:default]
            end
            if a.has_key?(:required)
              required = a[:required]
            end
          end
        end
        return { :name => name, :args => args, default: default, required: required, :proc => blk }
      end
    end
  end
end
