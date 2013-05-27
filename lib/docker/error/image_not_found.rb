module Docker
  module Error
  end
end

class Docker::Error::ImageNotFound < StandardError
end
