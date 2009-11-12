begin

  require 'spec/rake/spectask'

  def select_latest(spec_list)
    spec_plus_mtime = spec_list.map {|spec| [spec, File.mtime(spec)]}
    sorted = spec_plus_mtime.sort { |a, b| a[1] <=> b[1] }
    sorted.last[0] rescue nil
  end

  DEFAULT_OPTIONS = ['--backtrace']
  SPEC_FILE_PATTERN = 'spec/**/*_spec.rb'
  SPEC_FILES = FileList[SPEC_FILE_PATTERN]
  LATEST_SPEC = select_latest(SPEC_FILES)

  Spec::Rake::SpecTask.new do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = SPEC_FILES
    spec.spec_opts = DEFAULT_OPTIONS
  end

  namespace :spec do

    task :latest do
      puts "Running #{LATEST_SPEC}"
    end

    Spec::Rake::SpecTask.new(:latest) do |spec|
      spec.libs << 'lib' << 'spec'
      spec.spec_files = LATEST_SPEC
      spec.spec_opts = DEFAULT_OPTIONS
    end

    Spec::Rake::SpecTask.new do |spec|
      spec.libs << 'lib' << 'spec'
      spec.pattern = SPEC_FILE_PATTERN
      spec.rcov = true
    end

  end

rescue LoadError
  puts "rspec and/or rcov (or a dependency) not available. Install it with: sudo gem install rspec rcov"
end
