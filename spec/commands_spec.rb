require 'spec_helper'

describe Clitopic::Commands do

  context 'Without topic' do
    it 'should be include in global cmds' do
      expect(Clitopic::Commands.global_commands['root_cmd']).to eq RootCmd
    end

    context ".prepare_run" do
      it "should set @current_cmd" do
        Clitopic::Commands.prepare_run("root_cmd")
        expect(Clitopic::Commands.current_cmd).to eq RootCmd
      end

      it "@current_topic should be nil" do
        Clitopic::Commands.prepare_run("root_cmd")
        expect(Clitopic::Commands.current_topic).to be nil
      end

      it "should rescue to help cmd" do
        Clitopic::Commands.prepare_run("unknowncmd")
        expect(Clitopic::Commands.current_cmd).to eq 'help'
      end
    end
  end

  context 'With topic' do
    context ".prepare_run" do
      it "should set @current_cmd" do
      Clitopic::Commands.prepare_run("a:cmd")
        expect(Clitopic::Commands.current_cmd).to eq TopicaCmd
      end

      it "@current_topic should be the topic" do
        Clitopic::Commands.prepare_run("a:cmd")
        expect(Clitopic::Commands.current_topic).to be_a TopicA
      end

      it "should rescue to help cmd" do
        Clitopic::Commands.prepare_run("unknowncmd:titi")
        expect(Clitopic::Commands.current_cmd).to eq 'help'
      end

      it "should return index Cmd if no subcommand" do
        Clitopic::Commands.prepare_run("a")
        expect(Clitopic::Commands.current_cmd).to eq TopicaIndex
      end

    end

  end


end
