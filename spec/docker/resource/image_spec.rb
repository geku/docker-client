require 'spec_helper'

describe Docker::Resource::Image do
  let(:docker) { Docker::API.new(base_url: 'http://10.0.5.5:4243') }
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
  
  describe "push" do
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