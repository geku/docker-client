require 'spec_helper'

describe Docker::Resource::Image do
  let(:docker) { docker_resource }
  subject(:image) { docker.images }
  
  describe "list", :vcr do
    subject { image.list(all: true) }
    
    it { should be_kind_of(Array) }
    its(:size) { should >= 4 }
    it "includes latest base image" do
      subject.any? { |i| i["Repository"] == 'base' && i["Tag"] == 'latest' }.should be_true
    end
  end
  
  # We should name it 
  # * image/pull
  # * image/upload
  describe "create" do
  end
  
  describe "insert" do
  end
  
  describe "show", :vcr do
    subject { image.show('base') }
    
    it { should be_kind_of(Hash) }
    it { should have_key('id') }
    it { should have_key('container_config') }
    it "raises an exception for an unknown image" do
      expect {
        image.show("invalid_image")
      }.to raise_error(Docker::Error::ImageNotFound)
    end
  end
  
  describe "history", :vcr do
    subject(:image_history) { image.history('base') }
    
    it { should be_kind_of(Array) }
    its(:size) { should >= 2 }
    
    describe "step" do
      subject { image_history.first }
      it { should have_key('Id') }
      it { should have_key('Created') }
      it { should have_key('CreatedBy') }
    end
  end
  
  describe "insert_file", :vcr do
    after {
      details = image.show(@new_image_id)
      delete_containers(details['container'])
      delete_images(@new_image_id)
    }
    
    it "creates a new image with the file" do
      result = image.insert_file('base', '/tmp/new_file', 'https://raw.github.com/geku/docker-client/master/README.md')
      result.should be_kind_of(Hash)
      result.should have_key('Id')
      @new_image_id = result['Id']
      @new_image_id.should_not be_nil
    end
  end
  
  describe "tag", :vcr do
    before(:all) { @img = create_image('test-tag') }
    after(:all) { delete_images(@img) }
    
    it "an image into a repository" do
      status = image.tag('test-tag', 'test-repo')
      status.should be_true
    end
    
    it "raises an exception for an unknown image" do
      expect {
        image.tag('inavlid_image', 'test-repo')
      # }.to raise_error(Docker::Error::ImageNotFound)
      # Should return ImageNotFound, this is an error in Docker source! as it returns 500 and not 404
      }.to raise_error(Docker::Error::InternalServerError)
    end
  end
  
  describe "remove", :vcr do
    before(:all) { @image = create_image('test-image') }
    
    it "deletes the image" do
      subject.remove(@image)
    end
    
    it "raises an exception for an unknown image" do
      expect {
        subject.remove('unknown-image')
      }.to raise_error(Docker::Error::ImageNotFound)
    end
  end
  
  describe "push", :vcr do
    before {
      @image = create_image('push_image_test')
    }
    
    it "pushs the given image to the default registry" do
      status = subject.push(@image)
      status.should == 200
    end
    
    xit "returns the streamed progress" do
      output = []
      subject.push(@image) do |data|
        output << data
      end
      
      # TODO
      output.size.should >= 2
      output.last.should == ""
      # ???
    end
    
    xit "raises an exception for an unknown image" do
      expect {
        subject.push('invalid_image')
      }.to raise_error(Docker::Error::ImageNotFound)
    end
  end
  
  describe "pull" do
  end
  
  describe "build_from_url", :live, :vcr do
    it "creates a new image from a Dockerfile" do
      output = []
      status = subject.build_from_url('https://gist.github.com/geku/6821e658b8476f87bf63/raw/bb94ee905b7d7164980a0b5cd4e58da2a14d2537/Dockerfile') do |data|
        output << data
      end
      
      output.last.should =~ /^Successfully built \S{12}$/
      status.should == 200
    end
    
    it "creates a new image from a GIT repository" do
      output = []
      status = subject.build_from_url('git://github.com/dotcloud/hipache.git') do |data|
        output << data
      end
      
      output.last.should =~ /^Successfully built \S{12}$/
      status.should == 200
    end
    
    it "returns 500 for an invalid URL" do
      status = subject.build_from_url('http://www.besure.ch/invalid_url') {}
      status.should == 500
    end
    
  end
  
  describe "import" do
    # export busybox image to see if we can embed that into the Git repo
  end
  
  # FIXME not working with current Docker master
  # describe "search", :vcr do
  #   it "for an image in the docker index" do
  #     response = subject.search('sshd')
  #     response.should be_kind_of(Array)
  #     response.size.should >= 1
  #     response.first.should have_key('Name')
  #     response.first.should have_key('Description')
  #   end
    
  # end
  
  
  
  
  
end