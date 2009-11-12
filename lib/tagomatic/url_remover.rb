module Tagomatic

  class UrlRemover

    def initialize(options)
      @options = options
    end

    def process(tags_hash)
      return tags_hash unless @options[:removeurls]

      result = {}

      tags_hash.each do |tag,value|
        next unless value
        result[tag] = value.gsub(URL_REGEXP, '').gsub(/ by [a-zA-Z0-9]+[\w ]/, '')
      end

      result
    end

    URL_REGEXP = Regexp.compile("www\.[^\.]+\.[a-z]{2,4}", Regexp::IGNORECASE)

  end

end
