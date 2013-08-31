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
    @base_url = options[:base_url]
    raise(ArgumentError, ':base_url missing') unless @base_url
  end
  
  def get(path, params = {}, headers = {})
    resp = perform_request(:GET, path, params, headers)
    raise(Docker::Error::InternalServerError, resp.body) if resp.status == 500
    resp
  end
  
  def post(path, params = {}, body = '', headers = {})
    resp = perform_request(:POST, path, params, headers, body)
    raise(Docker::Error::InternalServerError, resp.body) if resp.status == 500
    resp
  end
  
  def delete(path, params = {}, headers = {})
    resp = perform_request(:DELETE, path, params, headers)
    raise(Docker::Error::InternalServerError, resp.body) if resp.status == 500
    resp
  end
  
  def stream(path, params = {}, timeout = nil, headers = {}, &block)
    raise(ArgumentError, 'Block required to handle streaming response') if block.nil?

    curl = curl_for(path, params, headers)

    begin
      timeout_raised = false
      curl.timeout = timeout if timeout
      curl.on_body {|data| block.call(data); data.size }
      curl.http(:POST)
    rescue Curl::Err::TimeoutError => e
      timeout_raised = true
    end

    Response.new(curl.body_str, curl.response_code, curl.content_type, timeout_raised)
  end
  
  
  private
    
    def perform_request(verb, path, query_params = {}, headers = {}, body = nil)
      curl = curl_for(path, query_params, headers, body)

      curl.http(verb)

      Response.new(curl.body_str, curl.response_code, curl.content_type)
    end
    
    def curl_for(path, query_params = {}, headers = {}, body = nil)
      Curl::Easy.new do |curl|
        set_url(curl, path, query_params)
        set_headers(curl, headers)
        set_body(curl, body)
      end
    end

    def set_body(curl, body)
      curl.post_body = body if body
    end
    
    def set_url(curl, path, query_params)
      params = query_params.collect do |key, value|
        "#{curl.escape(key)}=#{curl.escape(value)}"
      end
      param_str = params.empty? ? '' : "?#{params.join('&')}"
      curl.url = "#{@base_url}#{path}#{param_str}"
    end
    
    def set_headers(curl, headers)
      headers.each do |key, value|
        curl.headers[key] = value
      end
    end
  
end
