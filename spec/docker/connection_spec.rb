require 'spec_helper'

describe Docker::Connection, :vcr do
  subject { Docker::Connection.new(base_url: 'http://10.0.5.5:4243') }
  
  it "throws an error without a base_url configured" do
    expect {
      Docker::Connection.new({})
    }.to raise_error(ArgumentError, ':base_url missing')
  end
  
  it "sets given request headers" do
    subject.get('/pseudo_request', {}, {'Content-Type' => 'application/json'})
    WebMock.should have_requested(:get, "10.0.5.5:4243/pseudo_request").with(:headers => {'Content-Type' => 'application/json'})
  end
  
  it "sets given query parameters" do
    subject.get('/pseudo_params', {first: 'argument', second: 'param'})
    WebMock.should have_requested(:get, "10.0.5.5:4243/pseudo_params").with(:query => hash_including({'first' => 'argument', 'second' => 'param'}))
  end
  
  it "returns a valid response for a basic request" do
    response = subject.send(:perform_request, :GET, '/containers/ps', {}, {}, nil)
    response.should be_kind_of(Docker::Connection::Response)
    response.status.should == 200
    response.content_type.should == "application/json"
    response.body.should_not be_empty
  end
  
  it "returns status 404 for non existent path" do
    response = subject.send(:perform_request, :GET, '/invalid_path', {}, {}, nil)
    response.status.should == 404
  end
  
  it "returns a valid response for get request" do
    response = subject.get('/containers/ps?all=true', {})
    response.status.should == 200
    response.body.should_not be_empty
  end
  
  it "returns a valid response for post request" do
    id = create_container('connection_post')
    response = subject.post("/containers/#{id}/start", {}, '', {})
    response.status.should == 204
    response.body.should be_empty
    # clean up
    delete_containers(id)
  end
  
  it "raises an error for stream without block" do
    expect {
      subject.stream('/nothing') 
    }.to raise_error(ArgumentError, 'Block required to handle streaming response')
  end
  
  it "returns a stream", :live do
    id = create_and_start_container('test-returns-a-stream', command: hello_world_command)
    received_data = []
    params = {stream: 1, stdout: 1}
    timeout = 2
    
    response = subject.stream("/containers/#{id}/attach", params, timeout, {}) do |data|
      received_data << data
    end
    
    response.timeout.should be_true
    response.status.should == 200
    response.content_type.should == 'application/vnd.docker.raw-stream'
    response.body.should be_nil
    
    received_data.first.should == "hello world\n"
    received_data.size.should >= 1
    
    delete_containers(id)
  end
  
  
  # Alternative syntax
  # "Hello".should == 'Hello' 
  # expect("Hello").to eq("Hello")
end
