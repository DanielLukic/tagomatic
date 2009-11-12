require 'rake/testtask'

TEST_FILE_PATTERN = 'test/**/test_*.rb'

Rake::TestTask.new do |test|
  test.libs << 'lib' << 'test'
  test.pattern = TEST_FILE_PATTERN
  test.verbose = true
end

namespace :test do

  begin

    require 'rcov/rcovtask'

    Rcov::RcovTask.new do |test|
      test.libs << 'test'
      test.pattern = TEST_FILE_PATTERN
      test.verbose = true
    end

  rescue LoadError
    puts "rcov (or a dependency) not available. Install it with: sudo gem install rcov"
  end

end
