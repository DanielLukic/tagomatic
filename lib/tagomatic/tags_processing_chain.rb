module Tagomatic

  class TagsProcessingChain

    def initialize(options, tags_processor_factory, logger)
      @options = options
      @tags_processor_factory = tags_processor_factory
      @logger = logger
      create_processors
    end

    def process!(tags_hash)
      return if tags_hash.nil? or tags_hash.empty?
      @processors.each do |processor|
        tags_hash.merge! processor.process(tags_hash)
      end
    end

    protected

    def create_processors
      @processors = []
      @processors << @tags_processor_factory.create_url_remover if @options[:removeurls]
      @processors << @tags_processor_factory.create_tag_cleaner if @options[:cleantags]
      @processors << @tags_processor_factory.create_tag_normalizer
      @processors << @tags_processor_factory.create_tag_setter(@options)
    end

  end

end
