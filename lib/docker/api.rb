require 'docker/connection'

module Docker
end

class Docker::API
  
  def initialize(options)
    @debug           = options[:debug]
    @ssl             = options[:ssl] || { :verify => false }
    base_url         = options[:base_url]
    @conn = Docker::Connection.new(base_url: base_url)
    # @faraday_adapter = options[:faraday_adapter] || Faraday.default_adapter
    # @faraday         = options[:faraday]         || default_faraday
  end
  
  def containers
    Docker::Resource::Container.new(@conn)
  end
  
  def images
    Docker::Resource::Image.new(@conn)
  end
  
  def system
    
  end
  
  
  
  private 
    def default_faraday
      Faraday.new(:url => @base_url, :ssl => @ssl) do |faraday|
        faraday.use AuthenticationMiddleware, @client_id, @api_key
        faraday.request  :url_encoded
        faraday.response :rashify
        faraday.response :json
        faraday.response(:logger) if @debug
        faraday.adapter @faraday_adapter
      end
    end
  
end