require 'spec_helper'

describe Clitopic::Command::Version do
  context 'index' do
    it 'Call without argument should print Version' do
      expect{Clitopic::Command::Version.call}.to output("#{Clitopic.version}\n").to_stdout
    end
  end
end
