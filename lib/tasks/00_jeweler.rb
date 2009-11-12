begin

  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tagomatic"
    gem.summary = %Q{Simple command-line mp3 tagger based on mp3info gem. Supports folder-specific configuration files.}
    gem.description = File.read('README.rdoc')
    gem.email = "daniel.lukic@berlinfactor.com"
    gem.homepage = "http://github.com/DanielLukic/tagomatic"
    gem.authors = ["Daniel Lukic"]
    gem.add_dependency "ruby-mp3info", ">= 0"
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "rcov", ">= 0.8.1.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
