require 'tagomatic/format_parser'
require 'tagomatic/tags'

module Tagomatic

  class FormatCompiler

    include Tagomatic::Tags

    def initialize(object_factory, logger)
      @object_factory = object_factory
      @logger = logger
    end

    def compile_format(format)
      mapping = []

      parser = @object_factory.create_format_parser(format)
      regexp = Regexp.escape(parser.prefix)
      parser.each_tag_and_tail do |id, tail|
        tag = Tagomatic::Tags::TAGS_BY_ID[id]
        mapping << tag
        regexp << tag.regexp
        regexp << Regexp.escape(tail)
      end

      compiled = Regexp.compile(regexp, Regexp::IGNORECASE)
      @object_factory.create_format_matcher(compiled, mapping, format)
    rescue
      @logger.error "failed compiling #{format}", $!
      raise $!
    end

  end

end
