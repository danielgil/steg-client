require 'yaml'

module Stegclient

  class ParameterValidator
    def initialize(options)
       @options = options
    end

    def validate

      # Check mutually exclusive arguments
      rv = 0
      rv += 1 if @options.key?(:message)
      rv += 1 if @options.key?(:file)
      rv += 1 if @options.key?(:interactive)
      puts "Error: Exactly one input method '-f', '-m' and '-i' must be specified" unless rv == 1
      exit(1) unless rv

      # Check that the input file exists and is readable
      rv = check_file(@options[:file]) unless @options[:file].nil?
      exit(1) unless rv

      # Check that the Steganography methods are recognized

      # Check that the Steganography method configuration is valid

    end

    private
    # Returns true if file exists and is readable, false otherwise
    def check_file(path)
      rv = true
      unless File.file?(path)
        puts "Error: File '#{path}' does not exist or is a directory"
        rv = false
      end

      unless File.readable?(path)
        puts "Error: File '#{path}' is not readable"
        rv = false
      end
      rv
    end

  end

end