require 'tagomatic/local_options_matcher'

module Tagomatic

  class Scanner

    def initialize(options, parser, local_options_matcher_factory, logger)
      @options = options
      @parser = parser
      @local_options_matcher_factory = local_options_matcher_factory
      @logger = logger
      @options_stack = []
    end

    def process!(path_prefix, file_or_folder, &block)
      @file_path = path_prefix.nil? ? file_or_folder : File.join(path_prefix, file_or_folder)
      @logger.verbose "processing #{@file_path}"
      if is_taggable_file?
        yield @file_path
      elsif is_scannable?
        enter_scannable_folder(&block)
      end
    end

    protected

    def is_taggable_file?
      File.file?(@file_path) and File.extname(@file_path).downcase == '.mp3'
    end

    def is_scannable?
      @options[:recurse] and File.directory?(@file_path)
    end

    def enter_scannable_folder(&block)
      save_current_options
      apply_local_options if has_local_options?
      do_scan_folder(@file_path, &block)
      pop_local_options
    end

    def save_current_options
      @options_stack << @options.dup
    end

    def has_local_options?
      File.exist?(determine_local_config_file_path)
    end

    def determine_local_config_file_path
      File.join(@file_path, LOCAL_CONFIG_FILE_NAME)
    end

    def apply_local_options
      local_options = read_local_options
      @parser.parse!(local_options)
    end

    def read_local_options
      local_options = []
      matcher = @local_options_matcher_factory.create_local_options_matcher
      lines = File.readlines(determine_local_config_file_path)
      lines.each do |line|
        matcher.process!(line)
        local_options.concat matcher.to_argv
      end
      local_options
    end

    def do_scan_folder(folder_path, &block)
      @logger.verbose "scanning #{folder_path}"
      entries = Dir.entries(folder_path)

      local_formats = entries.select { |entry| entry.starts_with?('.format=') }
      apply_local_formats(local_formats)

      entries.each do |entry|
        next if entry == '.' or entry == '..' or entry.starts_with?('.format=')
        process!(folder_path, entry, &block)
      end
    end

    def apply_local_formats(list_of_local_format_file_names)
      local_formats = list_of_local_format_file_names.map do |file_name|
        format = file_name.sub('.format=', '')
        format.gsub!('|', '/')
      end
      @options[:formats].concat(local_formats)
    end

    def pop_local_options
      @options = @options_stack.pop
    end

    LOCAL_CONFIG_FILE_NAME = '.tagomatic'

  end

end
