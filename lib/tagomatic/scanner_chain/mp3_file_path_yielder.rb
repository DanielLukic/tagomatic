module Tagomatic

  class Mp3FilePathYielder

    def initialize(file_system)
      @file_system = file_system
    end

    def process_file(file_path, &block)
      extension = @file_system.extract_extension(file_path).downcase
      return unless extension == '.mp3'
      expanded_path = @file_system.expand_path(file_path)
      yield expanded_path
    end

    def continue_processing?(file_path)
      true
    end

    def enter_folder(folder_path)
      nil
    end

    def leave_folder(folder_path)
      nil
    end

  end

end
