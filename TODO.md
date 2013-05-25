# To Do

* Add Rake task to prepare live/recording test env!
* Error handling depending on status code.
* Document code with YARD
* Add thin layer of models (e.g. to create a new container)
* All connections need to be SSL
* Authentication is required for API (needs to be added on Docker side)
* Implement `export` of a container





# Resources

Faraday

* http://adventuresincoding.com/2010/09/writing-modular-http-client-code-with-faraday/
* http://www.intridea.com/blog/2012/3/12/faraday-one-http-client-to-rule-them-all


# Development Hints

## Streaming

Testing the streaming API is easy with CURL. Run on docker node:

    ./docker run -d base /bin/sh -c "while true; do echo hello world; sleep 1; done"

Now you can attach via web API to it

    curl -X POST "http://10.0.5.5:4243/containers/d1158045962d/attach?stream=1&stdout=1"

Code example with CURB

  easy = Curl::Easy.new
  easy.url = 'http://10.0.5.5:4243/containers/d1158045962d/attach?stream=1&stdout=1'
  # easy.timeout = 60     # to stop attaching after a certain time. Throws Curl::Err::TimeoutError
  easy.on_body {|data| puts "rec: #{data}"; data.size }
  easy.http('POST')   # blocks until connection is closed


## Docker Dev Environment

Start Docker from source

Follow the setup at http://docs.docker.io/en/latest/contributing/devenvironment.html abd execute

    sudo $GOPATH/bin/docker -d




