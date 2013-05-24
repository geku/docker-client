require 'spec_helper'

describe Docker::Resource::Container do
  subject { Docker::API.new(base_url: 'http://10.0.5.5:4243').containers }
  
  describe "lists", :vcr do
    # before(:all) {
    #   @c1 = create_container(command: hello_world_command)
    #   start_container(c1)
    #   @c2 = create_container
    # }
    
    it "all running containers" do
      containers = subject.list
      containers.should be_kind_of(Array)
      containers.size.should >= 1
      containers.first.should have_key("Id")
    end
    
    it "non-running processes too" do
      containers = subject.list(all: true)
      containers.size.should >= 2
      containers.last['Status'].should include('Exit')
    end
    
    it "limit last created containers" do
      containers = subject.list(limit: 1)
      containers.size.should == 1
    end
    
    it "processes before a certain created container" do
      containers = subject.list(before: '4c09094d460a')
      containers.first["Id"].should include('06c0af9e8696')
    end
    
    it "processes since a certain created container" do
      containers = subject.list(since: '06c0af9e8696')
      containers.first["Id"].should include('4c09094d460a')
    end
  end
  
  describe "create", :vcr do
    after {
      delete_container(@container_id)
    }
    
    it "with minimal settings" do
      status = subject.create(hello_world_command, 'base')
      status.should be_kind_of(Hash)
      status.should have_key('Id')
      status.should have_key('Warnings')
      status['Warnings'].should be_nil
      @container_id = status['Id']
    end
    
    it "with many settings" do
      options = {
        'Hostname' => 'test-container',
        'User' => 'test',
        'Memory' => 32.megabytes,
        'MemorySwap' => 64.megabytes,
        'CpuShares' => 1,
        'AttachStdin' => false,
        'AttachStdout' => true,
        'AttachStderr' => true,
        'PortSpecs' => ['80', '443'],
        'Tty' => false,
        'OpenStdin' => false,
        'StdinOnce' => false,
        'Env' => ['PORT=5000', 'ENVIRONTMENT=production'],
        'Dns' => nil,
        'Volumes' => {'/var/lib/app' => {}},
        'VolumesFrom' => ''
      }
      status = subject.create(['echo', 'hello world'], 'base', options)
      status.should be_kind_of(Hash)
      status.should have_key('Id')
      
      # TODO Compare with show
      @container_id = status['Id']
    end
    
    it "raises an exception when called with invalid options" do
      options = {
        'PortSpecs' => '443',
      }
      expect {
        subject.create(['echo', 'hello world'], 'base', options)
      }.to raise_error(Docker::Error::InternalServerError)
    end
    
  end
  
  describe "shows", :vcr do
    it "the low level details" do
      details = subject.show('4c09094d460a')
      details.should be_kind_of(Hash)
      details['Id'].should == '4c09094d460a43cd1fa68e779693ec8ed0b39ac6f2027d6b71ca448d61ff388a'
    end
  end
  
  describe "changes", :vcr do
    
    # TODO create around with creation and deletion of container 
    # if we are in recording mode
    
    it "inspects the container's filesystem changes" do
      changes = subject.changes('929274fd9a4f')
      changes.should be_kind_of(Array)
      changes.any? {|c| c['path'] == '/tmp/changes'}
    end
  end
  
  describe "export" do
  end
  
  # describe "start" do
  #   it "brings a container into running state" do
  #     state = subject.start('06c0af9e8696')
  #   end
  # end
  
  describe "stop" do
  end
  
  describe "restart" do
  end
  
  describe "kill" do
  end
  
  
  describe "remove", :vcr do
    let(:container_id) {
      create_container('Volumes' => {'/var/lib/app' => {}})
    }
    
    it "deletes the container" do
      status = subject.remove(container_id, true)
      status.should be_true
    end
    
    it "raises an exception with an invalid container" do
      expect {
        subject.remove('invalid_ID')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
end