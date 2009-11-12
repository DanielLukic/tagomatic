require 'fileutils'

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

    def rename(source_path, target_path)
      begin
        file_utils_mv source_path, target_path
      rescue Exception
        begin
          system_mv source_path, target_path
        rescue Exception
          read_and_write source_path, target_path
        end
      end
    end

    def cleaned_file_path(file_path, replacement = '')
      file_path.gsub(QUOTE_REGEXP) { |char| char == ' ' ? ' ' : replacement }
    end

    def quoted_file_path(file_path)
      file_path.gsub(QUOTE_REGEXP) { |char| "\\#{char}" }
    end

    protected

    def file_utils_mv(source_path, target_path)
      FileUtils.mv source_path, target_path
    end

    def system_mv(source_path, target_path)
      quoted_source = quoted_file_path(source_path)
      quoted_target = quoted_file_path(target_path)
      success = system(%Q[mv "#{quoted_source}" "#{quoted_target}"])
      source_gone = !File.exist?(source_path)
      target_exists = File.exist?(target_path)
      raise "failed renaming #{source_path} to #{target_path}" unless success and source_gone and target_exists
    end

    def read_and_write(source_path, target_path)
      raise 'NYI'
    end

    QUOTED_CHARACTERS = %q['`"$&!- ]
    QUOTE_REGEXP = Regexp.compile "([#{Regexp.escape(QUOTED_CHARACTERS)}])"

  end

end
