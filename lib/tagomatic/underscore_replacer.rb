module Tagomatic

  class UnderscoreReplacer

    def initialize(options, file_system, logger)
      @options = options
      @file_system = file_system
      @logger = logger
    end

    def process(context)
      @context = context
      return unless cleaning_required?
      log_rename_info
      try_renaming_file
    end

    protected

    def cleaning_required?
      get_clean_file_name != get_original_file_name
    end

    def get_clean_file_name
      clean = get_original_file_name.gsub('_', ' ')
    end

    def get_original_file_name
      file_path = @context.file_path
      @file_system.base_name(file_path)
    end

    def log_rename_info
      @logger.verbose "renaming #{get_original_file_name} to #{get_clean_file_name}"
    end

    def try_renaming_file
      begin
        rename_file
      rescue Exception
        handle_rename_file_failure
      end
    end

    def rename_file
      source_path = get_source_path
      target_path = get_target_path
      @file_system.rename source_path, target_path
      @context.file_path = target_path
    end

    def get_source_path
      @context.file_path
    end

    def get_target_path
      @file_system.join(get_folder_path, get_clean_file_name)
    end

    def get_folder_path
      @file_system.directory_name(get_source_path)
    end

    def handle_rename_file_failure
      @context.show_error "rename operation failed", $!
      @context.file_path = get_source_path
    end

  end

end
