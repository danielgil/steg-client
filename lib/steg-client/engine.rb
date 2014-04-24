
module Stegclient
  class Engine
    def initialize(options)
      @options = options
    end

    # Turns a plain text message into steganograms ready to be sent
    def encode(message)
      size = message.length.to_s.rjust(@options[:lengthsize],'0') #Padded with 0
      steganogram = @options[:knockcode] + size + message
      return steganogram
    end

    # Turns steganograms into plain text messages
    def decode(steganogram)
      # If it doesn't start with the knockcode, it's invalid
      unless steganogram.start_with?(@options[:knockcode])
        puts "Failed decoding invalid steganogram : '#{steganogram}'" if @options[:verbose]
        return nil
      end

      #steganogram = headers[headername]
      #steganogram.slice!(/.*#{@options[:knockcode]}/)
      #size = steganogram.slice!(0..2).to_i
      #steganogram.slice!(0..size)

      # Remove the knockcode
      steganogram.slice!(/#{@options[:knockcode]}/)

      # Extract the size field
      size = steganogram.slice!(0..2).to_i

      # Check that the length is correct
      unless steganogram.length == size
        puts "Failed decoding invalid steganogram : '#{steganogram}'" if @options[:verbose]
         return nil
      end
      steganogram
    end

    # Extracts a steganogram from the incoming request headers
    def extract(headers)
      case @options[:outputmethod].downcase
        when 'header'
          return extract_header(headers)
        when 'doesntexistyet'
          return 'hahaha'
        else
          puts "Failed to extract steganogram, unknown output method : '#{@options[:outputmethod]}'" if @options[:verbose]
          return nil
      end
    end

    # Injects a steganogram into the incoming requests headers
    def inject(steganogram, headers)

    end

    private
    def extract_header(headers)
        # Check if the header is present
        headername = @options[:outputmethodconfig].downcase
        unless headers.key?(headername)
          puts "Header not found in request : '#{headername}'" if @options[:verbose]
          return nil
        end

        steganogram    = headers[headername]

        # Remove all characters up to the start of the knockcode
        steganogram    = steganogram.slice(/#{@options[:knockcode]}.*/)

        # Extract the 'size' field and turn it into an integer
        sizefieldstart = @options[:knockcode].length
        sizefieldend   = sizefieldstart + @options[:lengthsize] - 1
        size = steganogram.slice(sizefieldstart..sizefieldend).to_i

        # Extract the full steganogram
        totalsize = @options[:knockcode].length + size + @options[:lengthsize]
        steganogram[0..totalsize-1]
    end

    def inject_header

    end


  end
end