module Tagomatic

  class Logger

    def initialize(options)
      @options = options
    end

    def verbose(message)
      puts message if @options[:verbose]
    end

  end

end
