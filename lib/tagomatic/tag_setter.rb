module Tagomatic

  class TagSetter

    def initialize(options)
      @options = options
    end

    def process(tags_hash)
      tags_hash[ARTIST] if @options[:artist]
      tags_hash[ALBUM] if @options[:album]
      tags_hash[DISCNUM] if @options[:discnum]
      tags_hash[GENRE] if @options[:genre]
      tags_hash[TRACKNUM] if @options[:tracknum]
      tags_hash[TITLE] if @options[:title]
      tags_hash[YEAR] if @options[:year]
      tags_hash
    end

  end

end
