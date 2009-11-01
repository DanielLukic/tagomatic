require 'tagomatic/format_compiler'
require 'tagomatic/object_factory'
require 'tagomatic/logger'
require 'tagomatic/mp3info_wrapper'
require 'tagomatic/options'
require 'tagomatic/options_parser'
require 'tagomatic/scanner'
require 'tagomatic/system_configuration'
require 'tagomatic/tagger'

module Tagomatic

  class Main

    def self.run!(*arguments)
      configuration = Tagomatic::SystemConfiguration.new do
        register :options => Tagomatic::Options.new
        register :parser => Tagomatic::OptionsParser.new(get_options)
        register :local_options_matcher_factory => Tagomatic::ObjectFactory.new
        register :logger => Tagomatic::Logger.new(get_options)
        register :scanner => Tagomatic::Scanner.new(get_options, get_parser, get_local_options_matcher_factory, get_logger)
        register :format_matcher_factory => Tagomatic::ObjectFactory.new
        register :compiler => Tagomatic::FormatCompiler.new(get_format_matcher_factory)
        register :mp3info => Tagomatic::Mp3InfoWrapper.new
        register :info_updater_factory => Tagomatic::ObjectFactory.new
        register :tagger => Tagomatic::Tagger.new(get_options, get_compiler, get_mp3info, get_info_updater_factory, get_logger)
      end

      parser = configuration[:parser]
      parser.parse!(arguments)

      new(configuration).run!
    end

    def initialize(configuration)
      @configuration = configuration
    end

    def run!
      options = @configuration[:options]

      show_known_formats_and_exit if options[:list]
      show_usage_and_exit if options[:files].empty?

      scanner = @configuration[:scanner]
      tagger = @configuration[:tagger]

      files = options[:files]
      files.each do |file|
        scanner.process!(nil, file) do |mp3filepath|
          tagger.process!(mp3filepath)
        end
      end
    end

    def show_usage_and_exit
      puts @configuration[:parser].show_help
      exit 1
    end

    def show_known_formats_and_exit
      puts Tagomatic::Tagger::KNOWN_FORMATS
      exit 1
    end

  end

end
