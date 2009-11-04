module Tagomatic

  class UrlRemover

    def process(tags_hash)
      result = {}
      tags_hash.each do |tag,value|
        result[tag] = value.gsub(/www\.[^\.]+\.[a-z]{2,4}/, '').gsub(/ by [a-zA-Z0-9]+[\w ]/, '')
      end
      result
    end

  end

end
