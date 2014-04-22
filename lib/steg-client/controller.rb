require 'thread'

module Stegclient

  class Controller
    # Two queues for the raw user input and the steganogram (headers+user input)
    @input
    @encodedinput
    # Two queues for the raw output received from the remote server and the decoded message
    @output
    @decodedoutput

    # Webrick proxy server
    @proxy

    # Threads for encoding and decoding the messages
    @encoder
    @decoder

    # Configuration
    @options

    def initialize(options, messages)
      @options       = options
      @input         = messages
      @encodedinput  = Queue.new
      @output        = Queue.new
      @decodedoutput = Queue.new
      @proxy = Stegclient::Server.new(options[:port], @encodedinput, @output)

      # Allow the user to termiate the server cleanly with Control-C
      Signal.trap('INT') do
        puts 'Stopping gracefully' if @options[:verbose]
        @proxy.stop
      end

      startEncoder
      startDecoder

      @proxy.start

    end

    def startEncoder
      puts 'Starting Encoder thread' if @options[:verbose]
      @encoder = Thread.new do
        loop do
          puts "Encoding..."
          message = @input.pop
          @encodedinput << encode(message)
        end
      end
    end

    def startDecoder
      puts 'Starting Decoder thread' if @options[:verbose]
      @decoder = Thread.new do
        loop do
          puts "Decoding..."
          message = @output.pop
          @decodedoutput << decode(message)
        end
      end
    end

    def encode(message)

    end

    def decode(message)

    end

  end
end

