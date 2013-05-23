require 'spec_helper'

describe Docker::API do
  subject { Docker::API.new(base_url: 'http://10.0.5.5:4243') }
  
  it "provides a container resource" do
    subject.containers.should be_kind_of(Docker::Resource::Container)
  end
  
  it "provides an image resource"  do
    subject.images.should be_kind_of(Docker::Resource::Image)
  end
  
  xit "provides a system resource" do
    
  end
  
  xit "provides a misc resource" do
    
  end
  
  it "sets up a connection object" do
    subject.connection.should_not be_nil
    subject.connection.should be_kind_of(Docker::Connection)
  end
  
  it "throws an error without a base_url configured" do
    expect {
      Docker::API.new({})
    }.to raise_error(ArgumentError, ':base_url missing')
  end
  
  
  # Alternative syntax
  # "Hello".should == 'Hello' 
  # expect("Hello").to eq("Hello")
end