require 'spec_helper'

describe Clitopic::Command::Suggestions do
  context 'Prefix' do
    it 'Call uncompleted command should display list of commands' do
      Clitopic::Command::Suggestions.arguments = ["clito:"]
      response =  ["clito:defaults_file", "clito:suggestions", "clito:version"].join("\n") + "\n"


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
