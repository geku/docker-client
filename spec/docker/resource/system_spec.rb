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
  
end