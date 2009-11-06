require 'tagomatic/format_matcher'
require 'tagomatic/format_parser'
require 'tagomatic/info_updater'
require 'tagomatic/local_options_matcher'
require 'tagomatic/tag_cleaner'
require 'tagomatic/tag_normalizer'
require 'tagomatic/tag_setter'
require 'tagomatic/url_remover'

module Tagomatic

  class ObjectFactory

    def create_local_options_matcher(*arguments)
      Tagomatic::LocalOptionsMatcher.new(*arguments)
    end

    def create_format_parser(*arguments)
      Tagomatic::FormatParser.new(*arguments)
    end

    def create_format_matcher(*arguments)
      Tagomatic::FormatMatcher.new(*arguments)
    end

    def create_info_updater(*arguments)
      Tagomatic::InfoUpdater.new(*arguments)
    end

    def create_url_remover(*arguments)
      Tagomatic::UrlRemover.new(*arguments)
    end

    def create_tag_cleaner(*arguments)
      Tagomatic::TagCleaner.new(*arguments)
    end

    def create_tag_normalizer(*arguments)
      Tagomatic::TagNormalizer.new(*arguments)
    end

    def create_tag_setter(*arguments)
      Tagomatic::TagSetter.new(*arguments)
    end

  end

end
