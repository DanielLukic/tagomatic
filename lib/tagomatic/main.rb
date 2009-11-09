require 'tagomatic/format_compiler'
require 'tagomatic/object_factory'
require 'tagomatic/logger'
require 'tagomatic/mp3info_wrapper'
require 'tagomatic/options'
require 'tagomatic/options_parser'
require 'tagomatic/scanner'
require 'tagomatic/system_configuration'
require 'tagomatic/tagger'
require 'tagomatic/tags_processing_chain'
require 'tagomatic/unix_file_system'

module Tagomatic

  class Main

    def self.run!(*arguments)
      configuration = Tagomatic::SystemConfiguration.new do
        register :options => Tagomatic::Options.new
        register :file_system => Tagomatic::UnixFileSystem.new
        register :options_parser => Tagomatic::OptionsParser.new(get_options)
        register :logger => Tagomatic::Logger.new(get_options)
        register :local_options_matcher => Tagomatic::LocalOptionsMatcher.new
        register :local_options => Tagomatic::LocalOptions.new(get_options, get_options_parser, get_local_options_matcher, get_logger)
        register :scanner => Tagomatic::Scanner.new(get_options, get_file_system, get_local_options, get_logger)
        register :object_factory => Tagomatic::ObjectFactory.new
        register :tags_processor_chain => Tagomatic::TagsProcessingChain.new(get_options, get_object_factory, get_logger)
        register :compiler => Tagomatic::FormatCompiler.new(get_object_factory, get_logger)
        register :mp3info => Tagomatic::Mp3InfoWrapper.new
        register :tagger => Tagomatic::Tagger.new(get_options, get_compiler, get_tags_processor_chain, get_mp3info, get_object_factory, get_logger)
      end

      parser = configuration.get_options_parser
      parser.parse!(arguments)

      new(configuration).run!
    end

    def initialize(configuration)
      @configuration = configuration
    end

    def run!
      list_of_files_and_folders.each do |file|
        process_file_or_folder file
      end
    end

    protected

    def list_of_files_and_folders
      @configuration[:options][:files]
    end

    def process_file_or_folder(file_or_folder)
      scanner.each_mp3(file_or_folder) do |mp3filepath|
        tagger.process!(mp3filepath)
      end
    end

    def scanner
      @configuration[:scanner]
    end

    def tagger
      @configuration[:tagger]
    end

  end

end
