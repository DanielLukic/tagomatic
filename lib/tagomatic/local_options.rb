module Tagomatic

  class LocalOptions

    LOCAL_OPTIONS_FILE_NAME = '.tagomatic'

    def initialize(options, options_parser, options_matcher, logger)
      @options = options
      @options_parser = options_parser
      @options_matcher = options_matcher
      @logger = logger
      @options_stack = []
    end

    def create_child_context
      cloned = @options.clone
      cloned[:formats] = @options[:formats].clone if @options[:formats]
      @options_stack << cloned
    end

    def apply_local_options(option_lines)
      local_options = process_option_lines(option_lines)
      @logger.verbose "applying local options: #{local_options}"
      @options_parser.parse!(local_options)
    end

    def pop_child_context
      previous_options = @options_stack.pop
      @options.replace(previous_options)
    end

    protected

    def process_option_lines(option_lines)
      local_options = []
      option_lines.each do |line|
        @options_matcher.process!(line)
        local_options.concat @options_matcher.to_argv
      end
      local_options
    end

  end

end
