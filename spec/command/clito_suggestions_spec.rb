require 'spec_helper'

describe Clitopic::Command::Suggestions do
  context 'Prefix' do
    it 'Call uncompleted command should display list of commands' do
      Clitopic::Command::Suggestions.arguments = ["clitopic:"]
      response =  ["clitopic:defaults_file", "clitopic:suggestions", "clitopic:version"].join("\n") + "\n"


      expect{Clitopic::Command::Suggestions.call}.to output(response).to_stdout
    end
  end
  context 'Mistake' do
    it 'Command `hep`  should propose `help`' do
      Clitopic::Command::Suggestions.arguments = ["hep"]
      expect{Clitopic::Command::Suggestions.call}.to output("help\n").to_stdout
    end
  end
end
