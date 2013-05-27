module Docker
  module Resource
  end
end

class Docker::Resource::Image < Docker::Resource::Base
  
  def list(options = {})
    @connection.get('/images/json', options).body_as_json
  end
  
  # Inspect an image
  def show(name)
    response = @connection.get("/images/#{name}/json")
    raise_if_image_not_found(response.status)
    response.body_as_json
  end
  
  def history(name)
    response = @connection.get("/images/#{name}/history")
    raise_if_image_not_found(response.status)
    response.body_as_json
  end
  
  
  def tag(name, repository, options = {})
    options = options.merge(repo: repository)
    status = @connection.post("/images/#{name}/tag", options).status
    raise_if_image_not_found(status)
    raise(BadParameterError) if status == 400
    status == 201
  end
  
  def remove(name)
    status = @connection.delete("/images/#{name}").status
    raise_if_image_not_found(status)
    status == 204
  end
  
  def search(term)
    params = {term: term}
    @connection.get("/images/search", params).body_as_json
  end
  
  private
  
    def raise_if_image_not_found(status)
      raise(Docker::Error::ImageNotFound) if status == 404
    end
  
end

  