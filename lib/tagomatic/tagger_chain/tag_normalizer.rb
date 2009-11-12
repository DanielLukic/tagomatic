module Tagomatic

  class TagNormalizer

    def process(tagger_context)
      normalized = Hash.new
      tagger_context.tags.each do |tag, value|
        next unless value

        split_by_spaces_and_underscores value
        strip_dashes_and_brackets
        drop_empty_words
        capitalize_words

        normalized[tag] = get_resulting_value
      end
      tagger_context.tags = normalized
    end

    def split_by_spaces_and_underscores(value)
      @parts = value.split(NORMALIZER_SPLIT_REGEX)
    end

    def strip_dashes_and_brackets
      @parts.map! { |part| part.sub(NORMALIZER_STRIP_LEFT, '').sub(NORMALIZER_STRIP_RIGHT, '') }
    end

    def drop_empty_words
      @parts = @parts.select { |part| not part.empty? }
    end

    def capitalize_words
      @parts.map! { |part| part.capitalize }
    end

    def get_resulting_value
      @parts.join(' ')
    end

    NORMALIZER_SPLIT_REGEX = /[ _-]+/

    NORMALIZER_LEFT_LITERALS = Regexp.escape('-([.')
    NORMALIZER_RIGHT_LITERALS = Regexp.escape('-)].')

    NORMALIZER_STRIP_LEFT = /^[#{NORMALIZER_LEFT_LITERALS}]+\s*/
    NORMALIZER_STRIP_RIGHT = /\s*[#{NORMALIZER_RIGHT_LITERALS}]+$/

  end

end
