require 'monkey/string'

module Tagomatic

  class Scanner

    def initialize(options, file_system, scanner_chain)
      @options = options
      @file_system = file_system
      @scanner_chain = scanner_chain
      @scann_stack = []
    end

    def each_mp3(file_or_folder_path, &block)
      @block = block
      process file_or_folder_path
    end

    protected

    def process(file_or_folder_path)
      @current_path = file_or_folder_path
      if is_processable_file?
        process_file &@block
      elsif recursive_scanning_enabled? and is_scannable_folder?
        process_folder @current_path
      end
    end

    def set_current_path(file_or_folder_path)
      @current_path = file_or_folder_path
    end

    def is_processable_file?
      @file_system.is_file?(@current_path)
    end

    def process_file(&block)
      @scanner_chain.process_file @current_path, &block
    end

    def recursive_scanning_enabled?
      @options[:recurse]
    end

    def is_scannable_folder?
      @file_system.is_directory?(@current_path)
    end

    def process_folder(folder_path)
      @scanner_chain.enter_folder folder_path
      process_folder_entries folder_path
      @scanner_chain.leave_folder folder_path
    end

    def process_folder_entries(folder_path)
      entries = @file_system.list_folder_entries(folder_path)
      entries.each do |entry|
        next if entry == '.' or entry == '..'
        entry_path = File.join(folder_path, entry)
        process entry_path
      end
    end

  end

end
