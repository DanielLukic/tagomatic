require 'tagomatic/format_matcher'
require 'tagomatic/info_updater'
require 'tagomatic/local_options_matcher'

module Tagomatic

  class ObjectFactory

    def create_local_options_matcher(*arguments)
      Tagomatic::LocalOptionsMatcher.new(*arguments)
    end

    def create_format_matcher(*arguments)
      Tagomatic::FormatMatcher.new(*arguments)
    end

    def create_info_updater(*arguments)
      Tagomatic::InfoUpdater.new(*arguments)
    end

  end

end
