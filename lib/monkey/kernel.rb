module Kernel

  def import(glob_spec)
    $LOAD_PATH.each do |lib_path|
      full_glob_spec = File.join(lib_path, glob_spec)
      found_files = Dir.glob(full_glob_spec)
      found_files.each do |import|
        next unless File.file?(import)
        require import.sub(/^#{lib_path}#{File::SEPARATOR}/, '')
      end
    end
  end

end
