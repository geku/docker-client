require 'spec_helper'

# TODO use always constant to be able to switch for rerecording VCR casettes
DEMO_CONTAINER_ID = '06c0af9e8696'

describe Docker::Connection, :vcr do
  subject { Docker::Connection.new(base_url: 'http://10.0.5.5:4243') }
  
  it "throws an error without a base_url configured" do
    expect {
      Docker::Connection.new({})
    }.to raise_error(ArgumentError, ':base_url missing')
  end
  
  it "sets given request headers" do
    subject.get('/pseudo_request', {'Content-Type' => 'application/json'})
    WebMock.should have_requested(:get, "10.0.5.5:4243/pseudo_request").with(:headers => {'Content-Type' => 'application/json'})
  end
  
  it "returns a valid response for a basic request" do
    response = subject.send(:perform_request, :GET, '/containers/ps', {})
    response.should be_kind_of(Docker::Connection::Response)
    response.status.should == 200
    response.content_type.should == "application/json"
    response.body.should_not be_empty
  end
  
  it "returns status 404 for non existent path" do
    response = subject.send(:perform_request, :GET, '/invalid_path', {})
    response.status.should == 404
  end
  
  it "returns a valid response for get request" do
    response = subject.get('/containers/ps?all=true', {})
    response.status.should == 200
    response.body.should_not be_empty
  end
  
  it "returns a valid response for post request" do
    response = subject.post('/containers/06c0af9e8696/stop', {})
    response.status.should == 204
    response.body.should be_empty
  end
  
  it "raises an error for stream without block" do
    expect {
      subject.stream('/nothing') 
    }.to  raise_error(ArgumentError, 'Block required to handle streaming response')
  end
  
  it "returns a stream", :live do
    received_data = []
    response = subject.stream('/containers/06c0af9e8696/attach?stream=1&stdout=1', 2, {}) do |data|
      received_data << data
    end
    
    response.timeout.should be_true
    response.status.should == 200
    response.content_type.should == 'application/vnd.docker.raw-stream'
    response.body.should be_nil
    
    received_data.first.should == "hello world\n"
    received_data.size.should >= 1
  end
  
  
  # Alternative syntax
  # "Hello".should == 'Hello' 
  # expect("Hello").to eq("Hello")
end