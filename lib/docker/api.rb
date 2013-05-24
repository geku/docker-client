require 'docker/connection'

module Docker
end

class Docker::API
  
  attr_reader :connection
  
  def initialize(options)
    @debug      = options[:debug]
    @ssl        = options[:ssl] || { :verify => false }
    base_url    = options[:base_url]
    @connection = Docker::Connection.new(base_url: base_url)
    # @faraday_adapter = options[:faraday_adapter] || Faraday.default_adapter
    # @faraday         = options[:faraday]         || default_faraday
  end
  
  def containers
    Docker::Resource::Container.new(@connection)
  end
  
  def images
    Docker::Resource::Image.new(@connection)
  end
  
  def system
    
  end
  
  
end