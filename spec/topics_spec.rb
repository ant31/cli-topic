require 'spec_helper'

describe Clitopic::Topics do

  it "Topics[key] = topic should add the topic" do
    topic = Clitopic::Topic::Base.new(name: 'new', description: 'desc')
    Clitopic::Topics["c"] = topic
    expect (Clitopic::Topics.topics['c']) == topic
  end

  it "Topics[key] = val should failed if it's not a Topic" do
    expect {Clitopic::Topics["c"] = 3}.to raise_error ArgumentError
  end

  it ".topics should return the dict" do
    expect(Clitopic::Topics.topics).to be_a Hash
  end

  it "Topics[key] should return the topic" do
    expect(Clitopic::Topics['a']).to be_a  TopicA
  end
end
