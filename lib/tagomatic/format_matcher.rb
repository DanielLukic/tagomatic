require 'tagomatic/tags'

module Tagomatic

  class FormatMatcher

    include Tagomatic::Tags

    def initialize(compiled_regexp, tag_mapping, original_format)
      @regexp = compiled_regexp
      @mapping = tag_mapping
      @format = original_format
    end

    def match(file_path)
      matchdata = @regexp.match(file_path)
      return nil unless matchdata
      return nil unless matchdata.captures.size == @mapping.size
      @tags = {}
      0.upto(@mapping.size - 1) do |index|
        value = matchdata.captures[index]
        value = normalize(value) if value
        @tags[@mapping[index]] = value
      end
      @tags[YEAR] ||= @tags[SURROUNDED_YEAR]
      return nil unless valid_constraints?
      @tags
    end

    def to_s
      @format
    end

    protected

    def normalize(value)
      value = value.gsub('_', ' ')
      parts = value.split(' ')
      downcased = parts.map {|p| p.downcase}
      downcased.join(' ')
    end

    def valid_constraints?
      valid_double_match_with_same_value?(FORMAT_ID_ARTIST, FORMAT_ID_ARTIST_AGAIN) &&
      valid_double_match_with_same_value?(FORMAT_ID_ALBUM, FORMAT_ID_ALBUM_AGAIN)
    end

    def valid_double_match_with_same_value?(base_tag, again_tag)
      return true unless @tags.has_key?(again_tag)
      return false unless @tags.has_key?(base_tag)
      return @tags[base_tag].casecmp(@tags[again_tag]) == STRING_CASECMP_IS_EQUAL
    end

    STRING_CASECMP_IS_EQUAL = 0

  end

end
