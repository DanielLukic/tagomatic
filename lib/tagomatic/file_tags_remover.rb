module Tagomatic

  class FileTagsRemover

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      return unless @options[:removetags]
      tagger_context.mp3.removetag1
      tagger_context.mp3.removetag2
    end

  end

end
