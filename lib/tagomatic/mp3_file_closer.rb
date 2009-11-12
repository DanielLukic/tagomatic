require 'tagomatic/tagger_exception'

module Tagomatic

  class Mp3FileCloser

    def process(tagger_context)
      tagger_context.mp3.close
    rescue
      raise Tagomatic::TaggerException.new("failed closing #{tagger_context.file_path} - file probably not updated", $!)
    end

  end

end
