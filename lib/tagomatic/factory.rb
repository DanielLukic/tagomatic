require 'forwardable'

require 'tagomatic/format_compiler'
require 'tagomatic/format_matcher'
require 'tagomatic/globals'
require 'tagomatic/logger'
require 'tagomatic/mp3info_wrapper'
require 'tagomatic/options_parser'
require 'tagomatic/options'
require 'tagomatic/scanner'
require 'tagomatic/tagger'

module Tagomatic

  class Factory

    def initialize(&block)
      @globals = Tagomatic::Globals.new
      instance_eval(&block) if block_given?
    end

    def create_logger
      Tagomatic::Logger.new(get_options)
    end

    def create_options
      Tagomatic::Options.new
    end

    def create_options_parser
      Tagomatic::OptionsParser.new(get_options)
    end

    def create_scanner
      Tagomatic::Scanner.new(get_options, get_parser, get_logger)
    end

    def create_tagger
      Tagomatic::Tagger.new(get_options, get_compiler, get_mp3info, get_logger)
    end

    def create_compiler
      Tagomatic::FormatCompiler.new(self)
    end

    def create_format_matcher(*arguments)
      Tagomatic::FormatMatcher.new(*arguments)
    end

    def create_mp3info
      Mp3InfoWrapper.new
    end

    extend Forwardable

    def_delegators :@globals, :retrieve, :register, :[], :[]=

    protected

    def get_options
      @globals.retrieve(:options)
    end

    def get_parser
      @globals.retrieve(:parser)
    end

    def get_compiler
      @globals.retrieve(:compiler)
    end

    def get_mp3info
      @globals.retrieve(:mp3info)
    end

    def get_logger
      @globals.retrieve(:logger)
    end

  end

end
