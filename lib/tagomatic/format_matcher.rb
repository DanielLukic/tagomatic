require 'tagomatic/tags'

require 'tagomatic/util/again_tags_validator'
require 'tagomatic/util/tags_hash_creator'

module Tagomatic

  class FormatMatcher

    include Tagomatic::Tags

    attr_reader :tags

    def initialize(compiled_regexp, tag_mapping, original_format)
      @regexp = compiled_regexp
      @mapping = tag_mapping
      @format = original_format
    end

    def reset
      @matchdata = nil
      @tags = nil
      @valid = false
    end

    def match(file_path)
      apply_regex_to file_path
      return unless matched?
      create_tags_hash
      set_year_from_surrounded_year_if_possible unless year_set?
      validate_constraints
    end

    def matched?
      @matchdata and @matchdata.captures and @matchdata.captures.size == @mapping.size
    end

    def valid_match?
      matched? and valid?
    end

    def to_s
      @format
    end

    protected

    def apply_regex_to(file_path)
      @matchdata = @regexp.match(file_path)
    end

    def create_tags_hash
      creator = Tagomatic::Util::TagsHashCreator.new(@mapping, @matchdata)
      @tags = creator.create_tags_hash
    end

    def set_year_from_surrounded_year_if_possible
      @tags[YEAR] ||= @tags[SURROUNDED_YEAR]
    end

    def year_set?
      @tags[YEAR]
    end

    def validate_constraints
      validator = Tagomatic::Util::AgainTagsValidator.new(@tags)
      @valid = validator.valid_constraints?
    end

    def valid?
      @valid
    end

  end

end
