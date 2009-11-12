require 'ostruct'

module Tagomatic

  class TaggerContext < OpenStruct

    def initialize(options, logger)
      super()
      @options = options
      @logger = logger
    end

    def reset_to(file_path)
      self.file_path = file_path
      self.tags = Hash.new
    end

    def show_error(message, optional_exception = nil)
      @logger.error(message, optional_exception)
      exit 10 if @options[:errorstops]
    end

    def has_tags?
      not (self.tags.nil? or self.tags.empty?)
    end

  end

end
