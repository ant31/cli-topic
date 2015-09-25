require 'clitopic/command/base'

module Clitopic
  module Command

    class Version < Clitopic::Command::Base
      register name: 'version',
      description: "Display version",
      banner: "Display version"
      class  << self
        def call
          puts Clitopic.version
        end
      end
    end
  end
end
