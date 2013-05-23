module Docker
  module Resource
  end
end

class Docker::Resource::Base
  def initialize(connection)
    @connection = connection
  end
  
  private
    
    # TODO add all methods to gather all HTTP calls in this superclass
    # Than it should be easier to replaces it for streaming support
    def get
      
    end
    
    
  
end

  