require 'tagomatic/known_formats'

module Tagomatic

  class FormatsApplier

    include Tagomatic::KnownFormats

    def initialize(options, format_compiler, file_system)
      @options = options
      @format_compiler = format_compiler
      @file_system = file_system
    end

    def process(tagger_context)
      @context = tagger_context
      if custom_formats_available?
        apply_custom_formats
      end
      if guessing_allowed? and not tags_already_set?
        apply_known_formats
      end
    end

    protected

    def custom_formats_available?
      @options[:formats] and not @options[:formats].empty?
    end

    def apply_custom_formats
      @formats_error_subject = "custom format"
      do_apply_formats @options[:formats]
    end

    def do_apply_formats(list_of_formats)
      @tags = guess_tags_using(list_of_formats) 
      if tags_found?
        store_tags_in_context
      else
        show_failed_matching_error
      end
    end

    def guess_tags_using(formats)
      formats.each do |format|
        format_matcher = @format_compiler.compile_format(format)
        matched_tags = format_matcher.match(@context.file_path)
        return matched_tags unless matched_tags.nil? or matched_tags.empty?
      end
      nil
    end

    def tags_found?
      not (@tags.nil? or @tags.empty?)
    end

    def store_tags_in_context
      @context.tags = @tags
    end

    def show_failed_matching_error
      @context.show_error "no #{@formats_error_subject} matched #{@context.file_path}"
    end

    def guessing_allowed?
      @options[:guess]
    end

    def tags_already_set?
      @context.has_tags?
    end

    def apply_known_formats
      @formats_error_subject = "guessable format"
      do_apply_formats KNOWN_FORMATS
    end

  end

end
