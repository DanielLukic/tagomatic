require 'tagomatic/local_options'

module Tagomatic

  class Scanner

    def initialize(options, file_system, local_options, logger)
      @options = options
      @file_system = file_system
      @local_options = local_options
      @logger = logger
    end

    def each_mp3(file_or_folder, &block)
      process(file_or_folder, &block)
    end

    protected

    def process(file_path, &block)
      @logger.verbose "processing #{file_path}"
      set_current_file_or_folder file_path
      if is_taggable_file?
        yield expanded_file_path
      elsif is_scannable?
        enter_scannable_folder(&block)
      end
    end

    def set_current_file_or_folder(file_path)
      @file_path = file_path
    end

    def is_taggable_file?
      @file_system.is_file?(@file_path) and @file_system.extract_extension(@file_path).downcase == '.mp3'
    end

    def expanded_file_path
      @file_system.expand_path(@file_path)
    end

    def is_scannable?
      @options[:recurse] and @file_system.is_directory?(@file_path)
    end

    def enter_scannable_folder(&block)
      folder_path = @file_path
      @logger.verbose "entering #{folder_path}"
      save_current_options
      apply_local_options if has_local_options?
      do_scan_folder(folder_path, &block)
      pop_local_options
      @logger.verbose "leaving #{folder_path}"
    end

    def save_current_options
      @local_options.create_child_context
    end

    def has_local_options?
      @file_system.exist?(determine_local_config_file_path)
    end

    def determine_local_config_file_path
      @file_system.join_path(@file_path, Tagomatic::LocalOptions::LOCAL_OPTIONS_FILE_NAME)
    end

    def apply_local_options
      option_lines = read_local_option_lines
      @local_options.apply_local_options option_lines
    end

    def read_local_option_lines
      @file_system.read_lines_without_linefeed(determine_local_config_file_path)
    end

    def do_scan_folder(folder_path, &block)
      @logger.verbose "scanning #{folder_path}"
      entries = @file_system.list_folder_sorted(folder_path)

      local_formats = entries.select { |entry| entry.starts_with?('.format=') }
      apply_local_formats(local_formats)

      entries.each do |entry|
        next if entry == '.' or entry == '..' or entry.starts_with?('.format=')
        file_path = @file_system.join_path(folder_path, entry)
        process(file_path, &block)
      end
    end

    def apply_local_formats(list_of_local_format_file_names)
      @logger.verbose "applying local formats: #{list_of_local_format_file_names}"
      local_formats = list_of_local_format_file_names.map do |file_name|
        format = file_name.sub('.format=', '')
        format.gsub!('|', '/')
      end
      @options[:formats].concat(local_formats)
    end

    def pop_local_options
      @local_options.pop_child_context
    end

  end

end
