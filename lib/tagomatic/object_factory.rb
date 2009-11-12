require 'tagomatic/format_matcher'
require 'tagomatic/format_parser'

module Tagomatic

  class ObjectFactory

    def create_format_parser(*arguments)
      Tagomatic::FormatParser.new(*arguments)
    end

    def create_format_matcher(*arguments)
      Tagomatic::FormatMatcher.new(*arguments)
    end

  end

end
