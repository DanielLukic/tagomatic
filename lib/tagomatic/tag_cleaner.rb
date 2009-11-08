module Tagomatic

  class TagCleaner

    def process(tags_hash)
      @tags = tags_hash

      artist = get_regexp_for('a')
      replace_regexp_in_tag artist, 'b'
      replace_regexp_in_tag artist, 't'

      album = get_regexp_for('b')
      replace_regexp_in_tag album, 't'

      @tags
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
