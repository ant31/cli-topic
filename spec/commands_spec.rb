require 'spec_helper'

describe Clitopic::Commands do

  context 'Without topic' do
    it 'should be include in global cmds' do
      expect(Clitopic::Commands.global_commands['root_cmd']).to eq RootCmd
    end

    context ".find_cmd" do
      it "should set current_cmd" do
        cmd, topic = Clitopic::Commands.find_cmd("root_cmd")
        expect(cmd).to eq RootCmd
      end

      it "topic should be nil" do
        cmd, topic = Clitopic::Commands.find_cmd("root_cmd")
        expect(topic).to be nil
      end

      it "unknow cmd should return nil" do
        cmd, topic = Clitopic::Commands.find_cmd("unknowncmd")
        expect(cmd).to eq nil
        expect(topic).to eq nil
      end
    end
  end

  context 'With topic' do
    context ".find_cmd" do
      it "command should be TopicaCmd" do
        cmd, topic = Clitopic::Commands.find_cmd("a:cmd")
        expect(cmd).to eq TopicaCmd
      end

      it "current_topic should be the topic 'a'" do
        cmd, topic = Clitopic::Commands.find_cmd("a:cmd")
        expect(topic).to be_a TopicA
      end

      it "unknown cmd should return nil" do
        cmd, topic = Clitopic::Commands.find_cmd("unknowncmd:titi")
        expect(cmd).to eq nil
        expect(topic).to eq nil
      end

      it "should return index Cmd if no subcommand" do
        cmd, index = Clitopic::Commands.find_cmd("a")
        expect(cmd).to eq TopicaIndex
        expect(index).to be_a TopicA
      end

    end

  end


end
