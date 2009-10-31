require "rubygems"
require "mp3info"

module Tagomatic

  class Mp3InfoWrapper

    def open(file_path, &block)
      Mp3Info.open(file_path, &block)
    end

  end

end
