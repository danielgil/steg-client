
module Stegclient
  class Engine
    def initialize(options)

    end

    # Turns a plain text message into steganograms ready to be sent
    def encode(message)

    end

    # Turns steganograms into plain text messages
    def decode(steganogram)

    end

    # Extracts a steganogram from the incoming request headers
    def extract(headers)

    end

    # Injects a steganogram into the incoming requests headers
    def inject(steganogram, headers)

    end


  end
end