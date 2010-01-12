require 'tagomatic/tag'

module Tagomatic

  module Tags

    AVAILABLE_TAGS = Array.new

    TAGS_BY_ID = Hash.new
    TAGS_BY_NAME = Hash.new

    MP3INFO_ID_BY_TAG = Hash.new

    def self.define(tag_name, tag_id, tag_regexp_string, mp3info_id = nil)
      new_tag = Tagomatic::Tag.new(tag_name, tag_id, tag_regexp_string)

      const_set tag_name, new_tag
      const_set "FORMAT_ID_#{tag_name}", tag_id
      const_set "FORMAT_REGEXP_#{tag_name}", tag_regexp_string

      AVAILABLE_TAGS << new_tag
      TAGS_BY_ID[tag_id] = new_tag
      TAGS_BY_NAME[tag_name] = new_tag
      MP3INFO_ID_BY_TAG[new_tag] = mp3info_id if mp3info_id
    end

    define 'ARTIST', 'a', '([^\/]+)', :artist
    define 'ARTIST_AGAIN', 'A', '([^-\/]+)' # do not allow dashes - 'AGAIN' is used mostly in file name part
    define 'ALBUM', 'b', '([^\/]+)', :album
    define 'ALBUM_AGAIN', 'B', '([^-\/]+)' # do not allow dashes - 'AGAIN' is used mostly in file name part
    define 'DISCNUM', 'd', '\s*([0-9]+)\s*'
    define 'GENRE', 'g', '([^\/]+)', :genre_s
    define 'IGNORE', 'i', '([^\/]+)'
    define 'TRACKNUM', 'n', '\s*\[?([0-9]+)\]?\s*', :tracknum
    define 'TITLE', 't', '([^\/]+)', :title
    define 'WHITESPACE', 's', '\s*'
    define 'EXTENDED_WHITESPACE', 'S', '[\s\-_\.]*'
    define 'YEAR', 'y', '\s*([0-9]{4})\s*', :year
    define 'SURROUNDED_YEAR', 'Y', '\s*[\(\[]([0-9]+)[\)\]]\s*'

  end

end
