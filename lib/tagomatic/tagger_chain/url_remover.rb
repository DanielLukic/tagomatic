module Tagomatic

  class UrlRemover

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      return unless @options[:removeurls]

      tagger_context.tags.each do |tag, value|
        next unless value
        value.gsub!(URL_REGEXP, '')
        value.gsub!(BY_REGEXP, '')
      end
    end

    URL_REGEXP = Regexp.compile("www\.[^\.]+\.[a-z]{2,4}", Regexp::IGNORECASE)
    BY_REGEXP = Regexp.compile("\s+by\s+[a-zA-Z0-9]+\s?", Regexp::IGNORECASE)

  end

end
