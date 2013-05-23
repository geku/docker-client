require 'curb'
require 'multi_json'

module Docker
end

class Docker::Connection
  
  class Response < Struct.new(:body, :status, :content_type)
    def body_as_json
      MultiJson.load(body)
    end
  end
    
  def initialize(options = {})
    @curl = Curl::Easy.new
    @base_url = options[:base_url]
    raise ArgumentError, ':base_url missing' unless @base_url
    
    
  # easy.url = 'http://10.0.5.5:4243/containers/d1158045962d/attach?stream=1&stdout=1'
  # # easy.timeout = 60     # to stop attaching after a certain time. Throws Curl::Err::TimeoutError
  # easy.on_body {|data| puts "rec: #{data}"; data.size }
  # easy.http('POST')   # blocks until connection is closed
  end
  
  def get(path, headers = {})
    perform_request(:GET, path, headers)
  end
  
  def post(path, headers = {})
    perform_request(:POST, path, headers)
  end
  
  def delete(path, headers = {})
    perform_request(:DELETE, path, headers)
  end
  
  # Needs a block
  def stream(path)
    
  end
  
  
  private
    
    def perform_request(verb, path, headers)
      @curl.url = "#{@base_url}#{path}"
      assign_headers(headers)
      # @curl.method(:GET)
      @curl.http(verb)
      Response.new(@curl.body_str, @curl.response_code, @curl.content_type)
    end
    
    def assign_headers(headers = {})
      # TODO assign headers to CURL
    # curl.headers["User-Agent"] = "myapp-0.0"
    end
  
end