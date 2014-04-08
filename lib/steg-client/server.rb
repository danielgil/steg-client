require 'webrick'
require 'webrick/httpproxy'

module Stegclient

  class Server
    def initialize(port, message)
        @proxy = WEBrick::HTTPProxyServer.new(
            :Port => port,
            :RequestCallback => Proc.new{|req,res| puts req.request_line, req.raw_header})
        trap("INT"){@proxy.shutdown}
        @proxy.start
    end

  end

end