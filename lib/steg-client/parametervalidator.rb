module Stegclient

  class ParameterValidator
    def initialize(options)
       @options = options
    end

    def validate
      rv = true
      rv = rv && check_file(@options[:config]) unless @options[:config].nil?
      rv = rv && check_file(@options[:file]) unless @options[:file].nil?

      # Check mutually exclusive arguments
      #rv = rv &&

      # Check that the config is valid YAML

      exit(1) unless rv
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