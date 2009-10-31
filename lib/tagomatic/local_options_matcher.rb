module Tagomatic

  class LocalOptionsMatcher

    def process!(line)
      @matchdata = LOCAL_OPTIONS_ENTRY_REGEX.match(line)
    end

    def is_valid_option?
      @matchdata.captures.size > 0
    end

    def get_option
      @matchdata.captures[OPTION_MATCH_GROUP_INDEX]
    end

    def has_value?
      @matchdata.captures.size > 2
    end

    def get_value
      @matchdata.captures[VALUE_MATCH_GROUP_INDEX]
    end

    def to_argv
      argv = []
      argv << get_option if is_valid_option?
      argv << get_value if has_value?
      argv
    end

    LOCAL_OPTIONS_ENTRY_REGEX = /(--[^ ]+)( (.+))?/

    OPTION_MATCH_GROUP_INDEX = 0

    VALUE_MATCH_GROUP_INDEX = 2

  end

end
