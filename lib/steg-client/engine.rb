
module Stegclient
  class Engine
    def initialize(options)
      @options = options
      # The 'Present' steganography method needs persistent data structures across multiple requests
      @presentqueue = Array.new
      @extractbuffer = Array.new
      @knockcodechar = Array.new
      @lengthfield = 0
    end

    # Turns a plain text message into steganograms ready to be sent
    def encode(message)
      size = message.length.to_s.rjust(@options[:lengthsize],'0') #Padded with 0
      @options[:knockcode] + size + message
    end

    # Turns steganograms into plain text messages
    def decode(steganogram)
      # If it doesn't start with the knockcode, it's invalid
      unless steganogram.start_with?(@options[:knockcode])
        puts "1 Failed decoding invalid steganogram : '#{steganogram}'" if @options[:verbose]
        return nil
      end

      # Remove the knockcode
      steganogram.slice!(/#{@options[:knockcode]}/)

      # Extract the size field
      size = steganogram.slice!(0..2).to_i

      # Check that the length is correct
      unless steganogram.length == size
        puts "2 Failed decoding invalid steganogram : '#{steganogram}'" if @options[:verbose]
         return nil
      end
      steganogram
    end

    # Extracts a steganogram from the incoming request headers
    def extract(headers)
      case @options[:outputmethod].downcase
        when 'header'
          return extract_header(headers)
        when 'present'
          return extract_present(headers)
        when 'doesntexistyet'
          return 'hahaha'
        else
          puts "Failed to extract steganogram, unknown output method : '#{@options[:outputmethod]}'" if @options[:verbose]
          return nil
      end
    end

    # Injects a steganogram into the incoming requests headers
    def inject(steganogram, headers)
      case @options[:inputmethod].downcase
        when 'header'
          return inject_header(steganogram, headers)
        when 'present'
          return inject_present(steganogram, headers)
        when 'doesntexistyet'
          return 'hahaha'
        else
          puts "Failed to inject steganogram, unknown input method : '#{@options[:inputmethod]}'" if @options[:verbose]
          return nil
      end
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

        # Check if the knock code is present
        unless steganogram =~ /#{@options[:knockcode]}/
          puts "Ignoring request, knock code not found : '#{steganogram}'" if @options[:verbose]
          return nil
        end

        # Remove all characters up to the start of the knockcode
        steganogram    = steganogram.slice(/#{@options[:knockcode]}.*/)
        steganogram.inspect

        # Extract the 'size' field and turn it into an integer
        sizefieldstart = @options[:knockcode].length
        sizefieldend   = sizefieldstart + @options[:lengthsize] - 1
        size = steganogram.slice(sizefieldstart..sizefieldend).to_i

        # Extract the full steganogram
        totalsize = @options[:knockcode].length + size + @options[:lengthsize]
        steganogram[0..totalsize-1]
    end

    def inject_header(steganogram, headers)
      # Check if the header is present, and create it empty if it's not
      headername = @options[:inputmethodconfig].downcase
      headers[headername] = [''] unless headers.key?(headername)

      # Add the new header
      headers[headername][0] << steganogram

    end

    def inject_present(steganogram, headers)

      # If the queue for the present method is empty, split the current steganogram into binary
      if @presentqueue.empty?
          steganogram.bytes.each do |number|
              char = Array.new(8) { |i| number[i] }.reverse!
              char.each {|bit| @presentqueue.push(bit)}
          end
          puts "New steganogram for Present method detected: '#{steganogram}' splitted into binary '#{@presentqueue}'" if @options[:verbose]
      end

      # Get the header name from the configuration options
      headername = @options[:inputmethodconfig].downcase.split[0]
      headercontent = @options[:inputmethodconfig].downcase.split[1..-1].join(' ')

      # If the first number of @presentqueue is 0, we make sure the header is present. Otherwise, we make sure it's absent.
      present = @presentqueue.shift

      headers.delete_if {|key, value| key == headername } if present == 0
      headers[headername] = [headercontent]                 if present == 1

    end

    def extract_present(headers)

      # Extract the bit from the headers and push it into the bit buffer
      headername = @options[:outputmethodconfig].downcase
      @knockcodechar.push(1) if headers.key?(headername)
      @knockcodechar.push(0) unless headers.key?(headername)

      # Once we have 8 bits, we can convert it to a char and push it into the extractbuffer
      if @knockcodechar.length == 8
        char = @knockcodechar.join
        @extractbuffer << Array(char.to_i(2)).pack('c')
        @knockcodechar = []
      else
        return nil
      end

      # Wait until we find the knockcode
      if @extractbuffer.join.length <= @options[:knockcode].length
        # If the buffer does not start with a partial part of the knockcode, reset it
        unless @options[:knockcode] =~ /^#{@extractbuffer.join}/
          @extractbuffer = []
        end
        return nil
      end

      # Wait until we find knockcode + lengthfield
      if  @extractbuffer.join.length == @options[:knockcode].length + @options[:lengthsize]
         @lengthfield = @extractbuffer.join[-@options[:lengthsize]..-1].to_i
         return nil
      end

      # Wait until we find knockcode + lengthfield + data
      if  @extractbuffer.join.length == @options[:knockcode].length + @options[:lengthsize] + @lengthfield
         return @extractbuffer.join
      end

      # By default, return nil
      nil
    end

  end



end