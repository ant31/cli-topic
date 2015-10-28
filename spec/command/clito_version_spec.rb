require 'spec_helper'

describe Clitopic::Command::ClitoVersion do
  context 'call' do
    it 'should returns current cli-topic version' do
      expect{Clitopic::Command::ClitoVersion.call}.to output("cli-topic version: #{Clitopic::VERSION}\n").to_stdout
    end
  end
end
