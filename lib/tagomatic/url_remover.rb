module Tagomatic

  class UrlRemover

    def process(tags_hash)
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
