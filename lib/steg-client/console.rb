require 'colorize'

module Stegclient
  class Console
    def initialize(input, output)
      @input = input
      @output = output
    end

    def start
      puts 'Starting Interactive mode'
      start_inputthread
      start_outputthread

    end

    private
    def start_inputthread
      Thread.new do
        loop do
          data = gets.chomp
          @input << data unless data == '' or data.nil?
        end

      end
    end

    def start_outputthread
      Thread.new do
        loop do
          message = @output.pop
          puts message.colorize(:blue)
        end
      end
    end

  end
end