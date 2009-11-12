require 'tagomatic/tags'

module Tagomatic

  module Util

    class AgainTagsValidator

      include Tagomatic::Tags

      def initialize(tags)
        @tags = tags
      end

      def valid_constraints?
        valid_double_match_with_same_value?(ARTIST, ARTIST_AGAIN) and
                valid_double_match_with_same_value?(ALBUM, ALBUM_AGAIN)
      end

      def valid_double_match_with_same_value?(base_tag, again_tag)
        return true unless @tags.has_key?(again_tag)
        return false unless @tags.has_key?(base_tag)
        return @tags[base_tag].casecmp(@tags[again_tag]) == STRING_CASECMP_EQUAL_VALUE
      end

      STRING_CASECMP_EQUAL_VALUE = 0

    end

  end

end
