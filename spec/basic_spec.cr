require "./spec_helper"

describe "Basic" do
  hailo = Hailo.new(order: 2)

  it "should instantiate" do
    hailo.is_a?(Hailo).should be_true
  end

  it "should reply with nothing" do
    hailo.reply.should be_nil
  end

  it "should learn and respond" do
    hailo.learn "foo bar baz"
    hailo.reply("bar").should eq "Foo bar baz."
  end
end
