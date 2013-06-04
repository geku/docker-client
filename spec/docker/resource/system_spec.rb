require 'spec_helper'

describe Docker::Resource::System do
  let(:docker) { Docker::API.new(base_url: 'http://10.0.5.5:4243') }
  subject(:system) { docker.system }
  
  describe "auth", :vcr do
    it "authenticates the user" do
      response = system.auth(ENV['DOCKER_USER'], ENV['DOCKER_EMAIL'], ENV['DOCKER_PASSWORD'])
      response.should be_kind_of(Hash)
      response.should have_key('Status')
      response['Status'].should == "Login Succeeded\n"
    end
  end
  
  describe "account", :vcr do
    it "returns the logged in user" do
      user = system.account
      user.should be_kind_of(Hash)
      user.should have_key('username')
      user.should have_key('email')
    end
  end
  
  describe "info", :vcr do
    it "returns system information" do
      info = system.info
      info.should be_kind_of(Hash)
      info.should have_key('Containers')
      info.should have_key('Images')
      info.should have_key('MemoryLimit')
      info.should have_key('SwapLimit')
    end
  end
  
  describe "version", :vcr do
    it "returns the Docker server version" do
      version = system.version
      version.should be_kind_of(Hash)
      version.should have_key('Version')
    end
  end
  
end