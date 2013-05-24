require 'curb'
require 'multi_json'

module Docker
end

class Docker::Connection
  
  class Response < Struct.new(:body, :status, :content_type, :timeout)
    def body_as_json
      MultiJson.load(body)
    end
  end
    
  def initialize(options = {})
    @curl = Curl::Easy.new
    @base_url = options[:base_url]
    raise ArgumentError, ':base_url missing' unless @base_url
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
  
  def stream(path, timeout = nil, headers = {}, &block)
    raise ArgumentError, 'Block required to handle streaming response' if block.nil?
    begin
      timeout_raised = false
      set_url(path)
      set_headers(headers)
      @curl.timeout = timeout if timeout
      @curl.on_body {|data| block.call(data); data.size }
      @curl.http(:POST)
    rescue Curl::Err::TimeoutError => e
      timeout_raised = true
    end
    Response.new(@curl.body_str, @curl.response_code, @curl.content_type, timeout_raised)
  end
  
  
  private
    
    def perform_request(verb, path, headers)
      set_url(path)
      set_headers(headers)
      @curl.http(verb)
      Response.new(@curl.body_str, @curl.response_code, @curl.content_type)
    end
    
    def set_url(path)
      @curl.url = "#{@base_url}#{path}"
    end
    
    def set_headers(headers)
      headers.each do |key, value|
        @curl.headers[key] = value
      end
    end
  
end