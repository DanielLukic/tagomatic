require 'tagomatic/tags'

module Tagomatic

  class TagCleaner

    include Tagomatic::Tags

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      return unless @options[:cleantags]

      @tags = tagger_context.tags

      artist = get_regexp_for(ARTIST)
      replace_regexp_in_tag artist, ALBUM
      replace_regexp_in_tag artist, TITLE

      album = get_regexp_for(ALBUM)
      replace_regexp_in_tag album, TITLE
    end

    def get_regexp_for(tag_id)
      value = @tags[tag_id]
      return nil unless value
      Regexp.compile("[ -]*#{Regexp.escape(value)}[ -]*", Regexp::IGNORECASE)
    end

    def replace_regexp_in_tag(regexp, tag_id)
      value = @tags[tag_id]
      value = value.sub(regexp, '') if value
      @tags[tag_id] = value unless value.nil? or value.empty?
    end

  end

end
