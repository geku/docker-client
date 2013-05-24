module Docker
  module Error
  end
end

class Docker::Error::NotFoundError < StandardError
end
