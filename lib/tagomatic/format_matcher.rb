module Tagomatic

  class FormatMatcher

    def initialize(compiled_regexp, tag_mapping, original_format)
      @regexp = compiled_regexp
      @mapping = tag_mapping
      @format = original_format
    end

    def match(file_path)
      matchdata = @regexp.match(file_path)
      return nil unless matchdata
      return nil unless matchdata.captures.size == @mapping.size
      tags = {}
      0.upto(@mapping.size) do |index|
        value = matchdata.captures[index]
        if value
          value = value.gsub('_', ' ')
          parts = value.split(' ')
          capitalized = parts.map {|p| p.capitalize}
          value = capitalized.join(' ')
        end
        tags[@mapping[index]] = value
      end
      tags
    end

    def to_s
      @format
    end

  end

end
