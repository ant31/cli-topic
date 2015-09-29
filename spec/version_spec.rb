require 'spec_helper'

describe Clitopic::VERSION do
  it "should be equal #{Clitopic::VERSION}" do
    expect(Clitopic::VERSION).to eql(Clitopic::VERSION)
  end
end
