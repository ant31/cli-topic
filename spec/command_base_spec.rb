require 'spec_helper'

describe Clitopic::Command::Base do

  context 'register' do
    context 'topic' do
      it 'without topic should add command to global' do
        expect(Clitopic::Commands.global_commands['root_cmd']).to eq RootCmd
      end

      it 'with topic name should add to existing topic' do
        expect(Clitopic::Topics['a'].commands["cmd"]).to eq TopicaCmd
        expect(Clitopic::Topics['a'].commands["index"]).to eq TopicaIndex
      end

      it 'with topic class should add to existing topic' do
        expect(Clitopic::Topics['b'].commands["index"]).to eq TopicbIndex
      end

      it 'with topic attributes should create a topic then add cmd' do
        expect(Clitopic::Topics['c'].commands["index"]).to eq TopiccIndex
      end
    end
  end
end
