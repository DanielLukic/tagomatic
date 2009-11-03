require 'tagomatic/tags'

module Tagomatic

  class FormatCompiler

    include Tagomatic::Tags

    def initialize(format_matcher_factory)
      @format_matcher_factory = format_matcher_factory
    end

    def compile_format(format)
      parts = format.split('%')
      prefix = parts.shift
      tag_mapping = []
      regexp = Regexp.escape(prefix)
      parts.each do |tag_and_tail|
        tag = tag_and_tail[0, 1]
        tail = tag_and_tail[1..-1]
        tag_mapping << tag
        regexp << FORMAT_REGEXP_ARTIST if tag == FORMAT_ID_ARTIST
        regexp << FORMAT_REGEXP_ARTIST_AGAIN if tag == FORMAT_ID_ARTIST_AGAIN
        regexp << FORMAT_REGEXP_ALBUM if tag == FORMAT_ID_ALBUM
        regexp << FORMAT_REGEXP_ALBUM_AGAIN if tag == FORMAT_ID_ALBUM_AGAIN
        regexp << FORMAT_REGEXP_DISC if tag == FORMAT_ID_DISC
        regexp << FORMAT_REGEXP_GENRE if tag == FORMAT_ID_GENRE
        regexp << FORMAT_REGEXP_IGNORE if tag == FORMAT_ID_IGNORE
        regexp << FORMAT_REGEXP_TITLE if tag == FORMAT_ID_TITLE
        regexp << FORMAT_REGEXP_TRACKNUM if tag == FORMAT_ID_TRACKNUM
        regexp << FORMAT_REGEXP_YEAR if tag == FORMAT_ID_YEAR
        regexp << Regexp.escape(tail)
      end

      compiled = Regexp.compile(regexp, Regexp::IGNORECASE)
      @format_matcher_factory.create_format_matcher(compiled, tag_mapping, format)
    end

  end

end
