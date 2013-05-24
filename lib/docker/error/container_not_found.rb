module Docker
  module Error
  end
end

class Docker::Error::ContainerNotFound < StandardError
end
