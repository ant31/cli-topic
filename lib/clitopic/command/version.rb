require 'clitopic/command/base'

module Clitopic
  module Command

    class Version < Clitopic::Command::Base
      register name: 'version',
      description: "show #{Clitopic.name} current version

Example:

 $ #{Clitopic.name} version
 #{Clitopic.version}
"
      class  << self
        def call
          puts Clitopic.version
        end
      end
    end
  end
end
