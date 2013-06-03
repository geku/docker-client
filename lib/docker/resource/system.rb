module Docker
  module Resource
  end
end

class Docker::Resource::System < Docker::Resource::Base
  
  def auth(user, email, password)
    body = {
      'username' => user,
      'email' => email,
      'password' => password
    }
    json_body = MultiJson.dump(body)
    @connection.post('/auth', {}, json_body).body_as_json
  end
  
  def account
    @connection.get('/auth').body_as_json
  end
  
  
end

  