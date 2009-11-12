require 'tagomatic/tagger_exception'

module Tagomatic

  class Mp3FileOpener

    def initialize(mp3info)
      @mp3info = mp3info
    end

    def process(tagger_context)
      tagger_context.mp3 = @mp3info.open(tagger_context.file_path)
    rescue
      raise Tagomatic::TaggerException.new("failed opening #{tagger_context.file_path}", $!)
    end

  end

end
