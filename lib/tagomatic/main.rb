require 'tagomatic/factory'
require 'tagomatic/options'

module Tagomatic

  class Main

    def self.run!(*arguments)
      factory = Tagomatic::Factory.new do
        register :options => create_options
        register :logger => create_logger
        register :parser => create_options_parser
        register :compiler => create_compiler
        register :mp3info => create_mp3info
      end

      parser = factory[:parser]
      parser.parse!(arguments)

      new(factory).run!
    end

    def initialize(factory)
      @factory = factory
    end

    def run!
      options = @factory[:options]
      scanner = @factory.create_scanner
      tagger = @factory.create_tagger

      show_usage_and_exit if options[:files].empty?
      show_known_formats_and_exit if options[:list]

      files = options[:files]
      files.each do |file|
        scanner.process!(nil, file) do |mp3filepath|
          tagger.process!(mp3filepath)
        end
      end
    end

    def show_usage_and_exit
      puts @factory[:parser]
      exit 1
    end

    def show_known_formats_and_exit
      puts Tagomatic::Tagger.KNOWN_FORMATS
      exit 1
    end

  end

end
