require 'tagomatic/tags'

module Tagomatic

  class TagSetter

    include Tagomatic::Tags

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      @tags = tagger_context.tags
      override_if_set ARTIST, :artist
      override_if_set ALBUM, :artist
      override_if_set DISCNUM, :artist
      override_if_set GENRE, :artist
      override_if_set TRACKNUM, :artist
      override_if_set TITLE, :artist
      override_if_set YEAR, :artist
    end

    def override_if_set(tag, option)
      value = @options[option]
      @tags[tag] = value if value
    end

  end

end
