module Tagomatic

  class ScannerActionLogger

    def initialize(logger)
      @logger = logger
    end

    def process_file(file_path, &block)
      @logger.verbose "processing #{file_path}"
    end

    def continue_processing?(file_path)
      true
    end

    def enter_folder(folder_path)
      @logger.verbose "entering #{folder_path}"
    end

    def leave_folder(folder_path)
      @logger.verbose "leaving #{folder_path}"
    end

  end

end
