require 'spec_helper'

describe Clitopic::Topic::Base do

  context 'register' do
    it 'should add topic to Topics' do
      expect(Clitopic::Topics['a']).to be_a  TopicA
    end

    it 'shoud Add instance to class' do
      expect(Clitopic::Topics['a']).to eq TopicA.instance
    end

    it 'should failed if the name is already taken' do
      expect {Topic.register(name: 'a', description: 'a bis')}.to raise_error Clitopic::TopicAlreadyExists
    end

    it 'should raise if no name is given' do
      expect {Topic.register(description: 'a bis')}.to raise_error ArgumentError
    end

    it '.name should return name registred' do
      expect(Clitopic::Topics['a'].name).to eq 'a'
    end

    it '.description should return description registred' do
      expect(Clitopic::Topics['a'].description).to eq 'describe a'
    end

    it '.hidden should return hidden registred' do
      expect(Clitopic::Topics['a'].hidden).to be false
    end

  end
end
