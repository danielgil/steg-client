require 'webrick'
require 'webrick/httpproxy'

module Stegclient

  class Server

    def initialize(port, encodedinput, output, engine)
        @inputqueue = encodedinput
        @outputqueue = output
        @engine = engine

        # Called before each request is sent to the server
        request_handler = proc do |req, res|
          puts req.request_line, req.raw_header
          output << "ASDF"
          @engine.inject(@outputqueue.pop, req.raw_header)
        end

        # Called after the response is received but before sending it to the browser
        response_handler = proc do |req, res|
          puts res.header,  res.body
          @inputqueue << @engine.extract(res.header)
        end

        # Define the proxy
        @proxy = WEBrick::HTTPProxyServer.new(
            :Port => port,
            :RequestCallback => request_handler,
            :ProxyContentHandler => response_handler
        )
    end

    def start
      @proxy.start
    end
    def stop
      @proxy.shutdown
    end

  end
end