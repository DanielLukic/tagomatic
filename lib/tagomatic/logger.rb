module Tagomatic

  class Logger

    def initialize(options)
      @options = options
    end

    def error(message, e)
      puts "ERROR: #{message}"
      $stderr.puts e.backtrace
    end

    def verbose(message)
      puts message if @options[:verbose]
    end

  end

end
