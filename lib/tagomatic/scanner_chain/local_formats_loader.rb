require 'monkey/string'

module Tagomatic

  class LocalFormatsLoader

    def initialize(options, file_system, logger)
      @options = options
      @file_system = file_system
      @logger = logger
      @local_formats_stack = []
    end

    def process_file(file_path, &block)
      nil
    end

    def continue_processing?(file_path)
      not @file_system.base_name(file_path).starts_with?(LOCAL_FORMAT_PREFIX)
    end

    def enter_folder(folder_path)
      list_of_local_format_file_names = read_local_formats(folder_path)
      list_of_local_formats = extract_local_formats(list_of_local_format_file_names)
      apply_local_formats list_of_local_formats
      @local_formats_stack.push list_of_local_formats
    end

    def leave_folder(folder_path)
      local_formats = @local_formats_stack.pop
      local_formats.each { |format| configured_formats.delete format }
    end

    protected

    def read_local_formats(folder_path)
      folder_entries = @file_system.list_folder_entries(folder_path)
      folder_entries.select { |entry| entry.starts_with?(LOCAL_FORMAT_PREFIX) }
    end

    def extract_local_formats(list_of_local_format_file_names)
      list_of_local_format_file_names.map do |file_name|
        format = file_name.sub(LOCAL_FORMAT_PREFIX, '')
        format.gsub! '|', '/'
      end
    end

    def apply_local_formats(list_of_local_formats)
      @logger.verbose "applying local formats: #{list_of_local_formats}"
      configured_formats.concat list_of_local_formats
    end

    def configured_formats
      @options[:formats] ||= []
    end

    LOCAL_FORMAT_PREFIX = '.format='

  end

end
