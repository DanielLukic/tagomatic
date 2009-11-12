begin

  require 'rake/rdoctask'

  VERSION_FILE = 'VERSION'
  README_FILE_PATTERN = 'README*'
  LIB_FILE_PATTERN = 'lib/**/*.rb'

  Rake::RDocTask.new do |rdoc|
    version = File.exist?(VERSION_FILE) ? File.read(VERSION_FILE) : ""

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "tagomatic #{version}"
    rdoc.rdoc_files.include(README_FILE_PATTERN)
    rdoc.rdoc_files.include(LIB_FILE_PATTERN)
  end

rescue LoadError
  puts "rdoc (or a dependency) not available. Install it with: sudo aptitude install rdoc or sudo gem install rdoc"
end
