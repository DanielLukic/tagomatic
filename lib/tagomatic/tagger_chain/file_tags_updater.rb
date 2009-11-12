require 'tagomatic/tags'

module Tagomatic

  class FileTagsUpdater

    include Tagomatic::Tags

    def initialize(info_updater)
      @info_updater = info_updater
    end

    def process(tagger_context)
      @info_updater.reset_to tagger_context.mp3

      discnum = tagger_context.tags[DISCNUM]
      discnum_suffix = discnum ? " CD#{discnum}" : ''

      tagger_context.tags.each do |tag, value|
        next unless tag and value
        next if tag == IGNORE

        @info_updater.album = value + discnum_suffix if tag == ALBUM
        @info_updater.artist = value if tag == ARTIST
        @info_updater.genre_s = value if tag == GENRE
        @info_updater.title = value if tag == TITLE
        @info_updater.tracknum = value.to_i if tag == TRACKNUM
        @info_updater.year = value if tag == YEAR
      end

      if @info_updater.dirty?
        @info_updater.apply
        puts "updated #{tagger_context.file_path}"
      end
    end

  end

end
