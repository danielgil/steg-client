require 'webrick'
require 'webrick/httpproxy'

module Stegclient

  class Server
    def initialize(port, message)

        # Called before each request is sent to the server
        request_handler = proc do |req, res|
          puts req.request_line, req.raw_header
        end

        # Called after the response is received but before sending it to the browser
        response_handler = proc do |req, res|
          puts res.header,  res.body
        end

        # Define the proxy
        @proxy = WEBrick::HTTPProxyServer.new(
            :Port => port,
            :RequestCallback => request_handler,
            :ProxyContentHandler => response_handler
        )

        # Allow the user to termiate the server cleanly with Control-C
        trap("INT"){@proxy.shutdown}

        # Start the server
        @proxy.start
    end

  end

end