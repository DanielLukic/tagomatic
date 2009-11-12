module Tagomatic

  class UnixFileSystem

    def directory_name(file_path)
      File.dirname(file_path)
    end

    def base_name(file_path)
      File.basename(file_path)
    end

    def expand_path(file_path)
      File.expand_path(file_path)
    end

    def join_path(*path_parts)
      File.join(path_parts)
    end

    def exist?(file_path)
      File.exist?(file_path)
    end

    def is_directory?(file_path)
      File.directory?(file_path)
    end

    def is_file?(file_path)
      File.file?(file_path)
    end

    def extract_extension(file_path)
      File.extname(file_path)
    end

    def read_lines_without_linefeed(file_path)
      File.readlines(file_path).map {|line| line.chomp}
    end

    def list_folder_entries(folder_path)
      Dir.entries(folder_path).sort
    end

  end

end
