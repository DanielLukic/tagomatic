module Tagomatic

  class Mp3InfoViewer

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      puts tagger_context.mp3 if @options[:verbose]
    end

  end

end
