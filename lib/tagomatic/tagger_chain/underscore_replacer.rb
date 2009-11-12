module Tagomatic

  class UnderscoreReplacer

    def initialize(options, file_system, logger)
      @options = options
      @file_system = file_system
      @logger = logger
    end

    def process(tagger_context)
      return unless @options[:replaceunderscores]
      @context = tagger_context
      return unless cleaning_required?
      log_rename_info
      rename_file
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
      @file_system.join_path(get_folder_path, get_clean_file_name)
    end

    def get_folder_path
      @file_system.directory_name(get_source_path)
    end

  end

end
