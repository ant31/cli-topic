require 'tempfile'
require 'spec_helper'

describe Clitopic do
  context 'global command load_defaults' do
    it 'option --defaults-file should be added to common options' do
      expect(Clitopic::Commands.global_options).to include (a_hash_including({:name => :load_defaults, :args =>[ "--defaults-file FILE", "Load default variables"]}))
    end

    it 'should not fail to load a default file' do
      temp = Tempfile.new('load_file')
      Clitopic::Command::DefaultsFile.arguments = [temp.path]
      Clitopic::Command::DefaultsFile.options = {:force => false}
      opts = Clitopic::Command::DefaultsFile.call
      cmd = Clitopic::Commands.global_options.select{|a| a[:name] == :load_defaults}.first
      Clitopic::Commands.current_cmd = Clitopic::Command::Help
      cmd[:proc].call(temp.path)
    end
  end
  context 'load_defaults?' do
    it 'should be true by default' do
      expect(Clitopic.load_defaults?).to be true
    end
    it 'should be false if set to' do
      Clitopic.load_defaults = false
      expect(Clitopic.load_defaults?).to be false
    end

  end
end
