require 'monkey/id3v2'
require 'monkey/kernel'
import 'tagomatic/*.rb'

module Tagomatic

  class Main

    def self.run!(*arguments)
      configuration = Tagomatic::SystemConfiguration.new do
        register :options => Tagomatic::Options.new
        register :file_system => Tagomatic::UnixFileSystem.new
        register :logger => Tagomatic::Logger.new(get_options)
        register :scanner_chain => Tagomatic::ScannerChain.new
        register :scanner => Tagomatic::Scanner.new(get_options, get_file_system, get_scanner_chain)
        register :tagger_context => Tagomatic::TaggerContext.new(get_options, get_logger)
        register :tagger_chain => Tagomatic::TaggerChain.new
        register :tagger => Tagomatic::Tagger.new(get_tagger_context, get_tagger_chain, get_logger)

        register :options_parser => Tagomatic::OptionsParser.new(get_options)
        register :local_options_matcher => Tagomatic::LocalOptionsMatcher.new
        register :local_options => Tagomatic::LocalOptions.new(get_options, get_options_parser, get_local_options_matcher, get_logger)

        register :object_factory => Tagomatic::ObjectFactory.new
        register :format_compiler => Tagomatic::FormatCompiler.new(get_object_factory, get_logger)
        register :mp3info_wrapper => Tagomatic::Mp3InfoWrapper.new
        register :info_updater => Tagomatic::InfoUpdater.new

        scanner_chain = get_scanner_chain
        scanner_chain.append Tagomatic::ScannerActionLogger.new(get_logger)
        scanner_chain.append Tagomatic::LocalOptionsLoader.new(get_local_options, get_file_system)
        scanner_chain.append Tagomatic::LocalFormatsLoader.new(get_options, get_file_system, get_logger)
        scanner_chain.append Tagomatic::Mp3FilePathYielder.new(get_file_system)

        tagger_chain = get_tagger_chain
        tagger_chain.append Tagomatic::UnderscoreReplacer.new(get_options, get_file_system, get_logger)
        tagger_chain.append Tagomatic::FormatsApplier.new(get_options, get_format_compiler, get_file_system)
        tagger_chain.append Tagomatic::UrlRemover.new(get_options)
        tagger_chain.append Tagomatic::TagCleaner.new(get_options)
        tagger_chain.append Tagomatic::TagNormalizer.new
        tagger_chain.append Tagomatic::TagSetter.new(get_options)
        tagger_chain.append Tagomatic::Mp3FileOpener.new(get_mp3info_wrapper)
        tagger_chain.append Tagomatic::FileTagsRemover.new(get_options)
        tagger_chain.append Tagomatic::Mp3InfoViewer.new(get_options)
        tagger_chain.append Tagomatic::FileTagsUpdater.new(get_info_updater)
        tagger_chain.append Tagomatic::TagsViewer.new(get_options)
        tagger_chain.append Tagomatic::Mp3FileCloser.new
      end

      parser = configuration.get_options_parser
      parser.parse! arguments

      new(configuration).run!
    end

    def initialize(configuration)
      @configuration = configuration
    end

    def run!
      list_of_files_and_folders.each { |entry| process_file_or_folder entry }
    end

    protected

    def list_of_files_and_folders
      @configuration[:options][:files]
    end

    def process_file_or_folder(file_or_folder_path)
      scanner.each_mp3(file_or_folder_path) do |mp3_file_path|
        tagger.process! mp3_file_path
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
