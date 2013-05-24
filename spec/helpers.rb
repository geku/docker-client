module Helpers
  
  def create_container(options = {})
    command = options.delete(:command) || 'env'
    subject.create(command, 'base', options)['Id']
  end
  
  def start_container(id)
    subject.start(id)
  end
  
  def delete_container(id)
    subject.remove(id, true) if id
  end
  
  def hello_world_command
    ['/bin/sh', '-c', 'while true; do echo hello world; sleep 1; done']
  end
  
end