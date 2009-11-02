module Tagomatic

  class Logger

    def initialize(options)
      @options = options
    end

    def error(message, optional_exception = nil)
      puts "ERROR: #{message}"
      $stderr.puts optional_exception.backtrace if optional_exception
    end

    def verbose(message)
      puts message if @options[:verbose]
    end

  end

end
