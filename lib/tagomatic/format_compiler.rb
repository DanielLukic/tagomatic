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
      tag_mapping = []

      parser = @object_factory.create_format_parser(format)
      regexp = Regexp.escape(parser.prefix)
      parser.each_tag_and_tail do |tag, tail|
        tag_mapping << tag
        regexp << Tagomatic::Tags::TAGS_BY_ID[tag].regexp
        regexp << Regexp.escape(tail)
      end

      compiled = Regexp.compile(regexp, Regexp::IGNORECASE)
      @object_factory.create_format_matcher(compiled, tag_mapping, format)
    rescue
      @logger.error "failed compiling #{format}", $!
      raise $!
    end

  end

end
