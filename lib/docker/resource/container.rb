
module Docker
  module Resource
  end
end

class Docker::Resource::Container < Docker::Resource::Base
  # TODO set 'Content-Type: application/json'
  
  # Options
  # all
  # limit
  # since
  # before
  def list(options = {})
    @connection.get('/containers/ps', options).body_as_json
  end
  
  def create(command, image = 'base', options = {})
    command = [command] if command.is_a?(String)
    body = {'Cmd' => command, 'Image' => image}
    body = options.merge(body)
    json_body = MultiJson.dump(body)
    
    response = @connection.post("/containers/create", {}, json_body, {'Content-Type' => 'application/json'})
    raise(Docker::Error::NotFoundError) if response.status == 404
    response.body_as_json
  end
  
  # inspect is a Ruby internal method that should not be overwritten 
  # therefore we use show as it displays the container details
  def show(container_id)
    @connection.get("/containers/#{container_id}/json").body_as_json
  end
  
  def changes(container_id)
    @connection.get("/containers/#{container_id}/changes").body_as_json
  end
  
  # Returns a stream
  def export
    
  end
  
  def start(container_id)
    status = @connection.post("/containers/#{container_id}/start").status
    raise_if_container_not_found(status)
    status == 204
  end
  
  def stop(container_id, timeout = nil)
    params = {}
    params['t'] = timeout if timeout
    status = @connection.post("/containers/#{container_id}/stop", params).status
    raise_if_container_not_found(status)
    status == 204
  end
  
  def restart(container_id, timeout = nil)
    params = {}
    params['t'] = timeout if timeout
    status = @connection.post("/containers/#{container_id}/restart", params).status
    raise_if_container_not_found(status)
    status == 204
  end
  
  def kill(container_id)
    status = @connection.post("/containers/#{container_id}/kill").status
    raise_if_container_not_found(status)
    status == 204
  end
  
  # Valid options:
  # stdout  true  default is false
  # stderr  true  default is false
  def attach(container_id, options = {}, timeout = nil, &block)
    raise(ArgumentError, "Block must be given to handle streamed data") if block.nil?
    options = {stdout: true, stderr: true} if options.empty?
    options = options.merge(stream: true, logs: false)
    
    response = @connection.stream("/containers/#{container_id}/attach", options, timeout, {}, &block)
    raise_if_container_not_found(response.status)
    raise(BadParameterError) if response.status == 400
    response
  end
  
  def logs(container_id, options = {})
    options = {stdout: true, stderr: true} if options.empty?
    options = options.merge(logs: true, stream: false)
    
    response = @connection.post("/containers/#{container_id}/attach", options)
    raise_if_container_not_found(response.status)
    raise(BadParameterError) if response.status == 400
    response.body
  end
  
  # Blocks until container exits
  def wait(container_id)
    response = @connection.post("/containers/#{container_id}/wait")
    raise_if_container_not_found(response.status)
    response.body_as_json
  end
  
  # Options:
  # v remove volumes of container
  def remove(container_id, delete_volumes = false)
    params = {v: delete_volumes}
    status = @connection.delete("/containers/#{container_id}", params).status
    raise_if_container_not_found(status)
    status == 204
  end
  
  private
  
    def raise_if_container_not_found(status)
      raise(Docker::Error::ContainerNotFound) if status == 404
    end
  
  
end

  








  