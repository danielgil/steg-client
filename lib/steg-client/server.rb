require 'webrick'
require 'webrick/httpproxy'

module Stegclient

  class Server

    def initialize(port, encodedinput, output, engine, logfile, verbose)
        @inputqueue = encodedinput
        @outputqueue = output
        @engine = engine

        # Called before each request is sent to the server
        request_handler = proc do |req, res|
          puts req.request_line, req.raw_header if verbose
          @engine.inject(@inputqueue.pop, req.header) unless @inputqueue.empty?
        end

        # Called after the response is received but before sending it to the browser
        response_handler = proc do |req, res|
          puts res.header,  res.body  if verbose
          message = @engine.extract(res.header)
          @outputqueue << message unless message.nil?
        end

        # Setup the logger
        if logfile == '/dev/null'
          logger = logfile
        else
          logger = File.open logfile, 'a+'
        end

        # Define the proxy
        @proxy = WEBrick::HTTPProxyServer.new(
            :Port                => port,
            :RequestCallback     => request_handler,
            :ProxyContentHandler => response_handler,
            :Logger              => WEBrick::Log.new(logger),
            :AccessLog           => [],
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