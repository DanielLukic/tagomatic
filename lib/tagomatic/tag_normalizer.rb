module Tagomatic

  class TagNormalizer

    def process(tags_hash)
      normalized = Hash.new
      tags_hash.each do |tag, value|
        next if value.nil?

        split_by_spaces_and_underscores value
        strip_dashes_and_brackets
        drop_empty_words
        capitalize_words

        normalized[tag] = get_resulting_value
      end
      normalized
    end

    def split_by_spaces_and_underscores(value)
      @parts = value.split(/[ _]+/)
    end

    def strip_dashes_and_brackets
      opening = Regexp.escape('-([.')
      closing = Regexp.escape('-)].')
      @parts.map! { |part| part.sub(/^[#{opening}]\s*/, '').sub(/\s*[#{closing}]$/, '') }
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

  end

end
