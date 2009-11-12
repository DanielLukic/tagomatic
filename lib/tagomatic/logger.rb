module Tagomatic

  class Logger

    def initialize(options)
      @options = options
    end

    def error(message, optional_exception = nil)
      puts "ERROR: #{message}"
      exception optional_exception if optional_exception
    end

    def exception(exception)
      verbose exception.to_s
      verbose exception.backtrace
    end

    def verbose(message)
      puts message if @options[:verbose]
    end

  end

end
