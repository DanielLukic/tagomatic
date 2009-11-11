module Tagomatic

  class LocalOptionsLoader

    def initialize(local_options, file_system)
      @local_options = local_options
      @file_system = file_system
    end

    def process_file(file_path, &block)
      nil
    end

    def continue_processing?(file_path)
      true
    end

    def enter_folder(folder_path)
      @folder_path = folder_path
      save_current_options
      apply_local_options if has_local_options?
    end

    def leave_folder(folder_path)
      restore_previous_options
    end

    protected

    def save_current_options
      @local_options.create_child_context
    end

    def has_local_options?
      @file_system.exist?(determine_local_config_file_path)
    end

    def determine_local_config_file_path
      @file_system.join_path(@folder_path, Tagomatic::LocalOptions::LOCAL_OPTIONS_FILE_NAME)
    end

    def apply_local_options
      option_lines = read_local_option_lines
      @local_options.apply_local_options option_lines
    end

    def read_local_option_lines
      @file_system.read_lines_without_linefeed(determine_local_config_file_path)
    end

    def restore_previous_options
      @local_options.pop_child_context
    end

  end

end
