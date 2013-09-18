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
  
  # Insert file and return ID of new image {'Id' => '<image ID>'}
  # Leaves behind a container that was used to download the file
  def insert_file(name, destination, url, timeout = nil)
    params = {path: destination, url: url}
    output = []
    response = @connection.stream("/images/#{name}/insert", params, timeout) do |data|
      output << data
    end
    
    MultiJson.load(output.last)
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
  
  # Import an image from the given file
  def import
    
  end
  
  
  # Pull an image from the given registry
  def pull(name, repository = nil, tag = nil, timeout = nil, &block)
    # TODO set standard repository if nil
    params = { fromImage: name }
    params[:repo] = repository if repository
    params[:tag]  = tag if tag
    if block.nil?
      response = @connection.post("/images/create", params)
    else
      response = @connection.stream("/images/create", params, timeout, &block)
    end
    response
  end
  
  
  # Params:
  # :registry   Registry to use
  def push(name, options = {}, timeout = nil, &block)
    status = nil
    if block.nil?
      status = @connection.post("/images/#{name}/push", options).status
    else
      status = @connection.stream("/images/#{name}/push", options, timeout, &block).status
    end
    raise_if_image_not_found(status)
    status
  end
  
    # Build from Dockerfile
  # Dockerfile as an IO object (either File IO or StringIO)
  # def build(dockerfile, options = {}, timeout  = nil, &block)
  #   docker_cmds = dockerfile.read
    
  #   # Content-Type: application/json
  #   @connection.stream("/build", options, timeout, &block).status
  # end
  
  # URL must be either a GIT repository or a URL to a Dockerfile.
  # 
  # Valid options
  # t       repository name and optionally a tag that is applied to the resulting image
  # q       suppress verbose build output [1|0]
  # nocache do not use the cache when building the image
  #
  # Last line stream is "Successfully built bfa2cdabeb02"
  def build_from_url(url, options = {}, timeout = nil, &block)
    
    # TODO URL muss encoded werden!!! -> sollte eigenltich CURB machen???
    
    params = options.merge({ remote: url })
    @connection.stream("/build", params, timeout, &block).status
  end
  
  private
  
    def raise_if_image_not_found(status)
      raise(Docker::Error::ImageNotFound) if status == 404
    end
  
end

  