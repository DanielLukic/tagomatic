module Tagomatic

  class FormatCompiler

    FORMAT_REGEXP_ARTIST = '([^\/]+)'
    FORMAT_REGEXP_ALBUM = '([^\/]+)'
    FORMAT_REGEXP_DISC = '([0-9]+)'
    FORMAT_REGEXP_GENRE = '([^\/]+)'
    FORMAT_REGEXP_IGNORE = '([^\/]+)'
    FORMAT_REGEXP_TITLE = '([^\/]+)'
    FORMAT_REGEXP_TRACKNUM = '([0-9]+)'
    FORMAT_REGEXP_YEAR = '([0-9]+)'

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
        regexp << FORMAT_REGEXP_ALBUM if tag == Tagomatic::Tagger::FORMAT_ID_ALBUM
        regexp << FORMAT_REGEXP_ARTIST if tag == Tagomatic::Tagger::FORMAT_ID_ARTIST
        regexp << FORMAT_REGEXP_DISC if tag == Tagomatic::Tagger::FORMAT_ID_DISC
        regexp << FORMAT_REGEXP_GENRE if tag == Tagomatic::Tagger::FORMAT_ID_GENRE
        regexp << FORMAT_REGEXP_IGNORE if tag == Tagomatic::Tagger::FORMAT_ID_IGNORE
        regexp << FORMAT_REGEXP_TITLE if tag == Tagomatic::Tagger::FORMAT_ID_TITLE
        regexp << FORMAT_REGEXP_TRACKNUM if tag == Tagomatic::Tagger::FORMAT_ID_TRACKNUM
        regexp << FORMAT_REGEXP_YEAR if tag == Tagomatic::Tagger::FORMAT_ID_YEAR
        regexp << Regexp.escape(tail)
      end

      compiled = Regexp.compile(regexp)
      @format_matcher_factory.create_format_matcher(compiled, tag_mapping, format)
    end

  end

end
