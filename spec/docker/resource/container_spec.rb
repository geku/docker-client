require 'spec_helper'

describe Docker::Resource::Container do
  subject(:containers) { Docker::API.new(base_url: 'http://10.0.5.5:4243').containers }
  
  describe "lists", :vcr do
    before(:all) {
      @c1 = create_and_start_container('container_lists1', command: hello_world_command)
      @c2 = create_container('container_lists2')
    }
    after(:all) { delete_containers(@c1, @c2) }
    
    it "all running containers" do
      containers = subject.list
      containers.should be_kind_of(Array)
      containers.size.should >= 1
      containers.first.should have_key("Id")
      containers.first['Status'].should include('Up')
    end
    
    it "non-running processes too" do
      containers = subject.list(all: true)
      containers.size.should >= 2
      containers.first['Status'].should include('Exit')
    end
    
    it "limit last created containers" do
      containers = subject.list(limit: 1)
      containers.size.should == 1
    end
    
    it "processes before a certain created container" do
      containers = subject.list(before: @c2)
      containers.first["Id"].should include(@c1)
    end
    
    it "processes since a certain created container" do
      containers = subject.list(since: @c1)
      containers.first["Id"].should include(@c2)
    end
  end
  
  describe "create", :vcr do
    after {
      delete_containers(@container_id)
    }
    
    it "with minimal settings" do
      status = subject.create(hello_world_command, 'base')
      status.should be_kind_of(Hash)
      status.should have_key('Id')
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
    before(:all) { @c = create_container('container_shows') }
    after(:all) { delete_containers(@c)}
    
    it "the low level details" do
      details = subject.show(@c)
      details.should be_kind_of(Hash)
      details['Id'].should include(@c)
    end
  end
  
  describe "changes", :vcr do
    before(:all) { 
      @c = create_and_start_container('container_changes', command: ['touch', '/tmp/changes'], wait: true)
    }
    after(:all) { delete_containers(@c) }
    
    it "inspects the container's filesystem changes" do
      changes = subject.changes(@c)
      changes.should be_kind_of(Array)
      changes.any? {|c| c['Path'] == '/tmp/changes'}.should be_true
    end
  end
  
  describe "commit", :vcr do
    before(:all) {
      @c = create_and_start_container('container_commit', command: ['touch', '/tmp/changes'], wait: true)
    }
    after(:all) { delete_containers(@c) }
    
    it "creates a new image from the container's changes" do
      options = {m: 'Commit message', author: 'Docker Client' }
      response = subject.commit(@c, 'test-repo', 'test-tag', options)
      response.should have_key('Id')
      image_id = response['Id']
      delete_images(image_id)
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.commit('invalid_id', 'test-repo')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
  describe "export" do
    # not yet implemented
  end
  
  describe "start", :vcr do
    before(:all) { @c = create_container('container_start') }
    after(:all) { delete_containers(@c)}
    
    it "brings a container into state running" do
      started = subject.start(@c)
      started.should be_true
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.start('invalid_id')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
  describe "stop", :vcr do
    before(:all) {
      @c = create_and_start_container('container_stop', command: hello_world_command)
    }
    after(:all) { delete_containers(@c) }
    
    it "halts a container" do
      stopped = subject.stop(@c, 5)
      stopped.should be_true
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.stop('invalid_id')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
  describe "restarts", :vcr do
    before(:all) {
      @c = create_and_start_container('container_restarts', command: hello_world_command)
    }
    after(:all) { delete_containers(@c) }
    
    it "the container" do
      status = subject.restart(@c, 3)
      status.should be_true
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.restart('invalid_id')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
    
  end
  
  describe "kill", :vcr do
    before(:all) {
      @c = create_and_start_container('container_kill', command: hello_world_command)
    }
    after(:all) { delete_containers(@c) }
    
    it "the container" do
      status = subject.kill(@c)
      status.should be_true
    end
    
    it "raises an exception for an unknow container" do
      expect {
        subject.kill('invalid_id')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
  describe "attach", :vcr, :live do
    before(:all) {
      @c = create_and_start_container('container_attach', command: hello_world_command)
    }
    after(:all) { delete_containers(@c) }
    
    it "returns stdout/stderr by default as a stream" do
      received_data = []
      timeout = 3
    
      response = subject.attach(@c, {}, timeout) do |data|
        received_data << data
      end
      
      response.timeout.should be_true
      response.status.should == 200
      response.content_type.should == 'application/vnd.docker.raw-stream'
      response.body.should be_nil
      
      received_data.first.should == "hello world\n"
      received_data.size.should >= 2
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.attach('invalid_id') {  }
      }.to raise_error(Docker::Error::ContainerNotFound)
    end 
  end
  
  describe "logs", :vcr do
    before(:all) { 
      @c = create_and_start_container('container_logs', command: ['/bin/sh', '-c', 'echo stdout; echo stderr 1>&2'], wait: true)
    }
    after(:all) { delete_containers(@c) }
    
    it "returns the stdout of a container" do
      output = subject.logs(@c, {stdout: true})
      output.should include("stdout")
    end
    
    it "returns the stderr of a container" do
      output = subject.logs(@c, {stderr: true})
      output.should include("stderr")
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.logs('invalid_id')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
  describe "wait", :vcr do
    before(:all) { 
      @c = create_and_start_container('container_wait', command: ['sleep', '3'])
    }
    after(:all) { delete_containers(@c) }
    
    it "blocks until the container stops" do
      status = subject.wait(@c)
      status.should be_kind_of(Hash)
      status.should have_key('StatusCode')
      status['StatusCode'].should == 0
    end
    
    it "raises an exception for an unknown container" do
      expect {
        subject.wait('invalid_id')
      }.to raise_error(Docker::Error::ContainerNotFound)
    end
  end
  
  describe "remove", :vcr do
    let(:container_id) {
      create_container('container_remove', 'Volumes' => {'/var/lib/app' => {}})
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