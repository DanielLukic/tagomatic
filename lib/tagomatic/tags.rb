require 'tagomatic/tag'

module Tagomatic

  module Tags

    AVAILABLE_TAGS = []

    TAGS_BY_ID = {}
    TAGS_BY_NAME = {}

    def self.define(tag_name, tag_id, tag_regexp_string)
      new_tag = Tagomatic::Tag.new(tag_name, tag_id, tag_regexp_string)
      const_set tag_name, new_tag
      const_set "FORMAT_ID_#{tag_name}", tag_id
      const_set "FORMAT_REGEXP_#{tag_name}", tag_regexp_string

      AVAILABLE_TAGS << new_tag
      TAGS_BY_ID[tag_id] = new_tag
      TAGS_BY_NAME[tag_name] = new_tag
    end

    define 'ARTIST', 'a', '([^\/]+)'
    define 'ARTIST_AGAIN', 'A', '([^-\/]+)' # do not allow dashes - 'AGAIN' is used mostly in file name part
    define 'ALBUM', 'b', '([^\/]+)'
    define 'ALBUM_AGAIN', 'B', '([^-\/]+)' # do not allow dashes - 'AGAIN' is used mostly in file name part
    define 'DISC', 'd', '\s*([0-9]+)\s*'
    define 'GENRE', 'g', '([^\/]+)'
    define 'IGNORE', 'i', '([^\/]+)'
    define 'TRACKNUM', 'n', '\s*\[?([0-9]+)\]?\s*'
    define 'TITLE', 't', '([^\/]+)'
    define 'WHITESPACE', 's', '\s*'
    define 'EXTENDED_WHITESPACE', 'S', '[\s\-_\.]*'
    define 'YEAR', 'y', '\s*([0-9]{4})\s*'
    define 'SURROUNDED_YEAR', 'Y', '\s*[\(\[]([0-9]+)[\)\]]\s*'

  end

end
