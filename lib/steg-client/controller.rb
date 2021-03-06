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

    # Steganography engine, takes care of encoding/decoding messages and injecting headers
    @engine

    def initialize(options, messages, responses)
      @options       = options
      @input         = messages
      @encodedinput  = Queue.new
      @output        = Queue.new
      @decodedoutput = responses
      @engine        = Stegclient::Engine.new(options)
      @proxy         = Stegclient::Server.new(options[:port], @encodedinput, @output, @engine, @options[:logfile], @options[:verbose])

      # Allow the user to terminate the server cleanly with Control-C
      Signal.trap('INT') do
        puts 'Stopping gracefully' if @options[:verbose]
        @proxy.stop
      end
    end

    def start_proxy
      @proxy.start
    end

    def start_encoder
      puts 'Starting Encoder thread' if @options[:verbose]
      @encoder = Thread.new do
        loop do
          message = @input.pop
          @encodedinput << @engine.encode(message)
        end
      end
    end

    def start_decoder
      puts 'Starting Decoder thread' if @options[:verbose]
      @decoder = Thread.new do
        loop do
          message = @output.pop
          @decodedoutput << @engine.decode(message)
        end
      end
    end

  end
end

