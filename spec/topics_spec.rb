require 'spec_helper'

describe Clitopic::Topics do

  it "Topics[key] = topic should add the topic" do
    Clitopic::Topics["c"] = TopicA
    expect (Clitopic::Topics.topics['c']) == TopicA
  end

  it "Topics[key] = val should failed if it's not a Topic" do
    expect {Clitopic::Topics["c"] = 3}.to raise_error ArgumentError
  end

  it ".topics should return the dict" do
    expect(Clitopic::Topics.topics).to be_a Hash
  end

  it "Topics[key] should return the topic" do
    expect(Clitopic::Topics['a']) ==  TopicA
  end
end
