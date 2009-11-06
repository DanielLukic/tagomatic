module Tagomatic

  class TagsProcessingChain

    def initialize(options, object_factory, logger)
      @options = options
      @object_factory = object_factory
      @logger = logger
    end

    def process!(tags_hash)
      return if tags_hash.nil? or tags_hash.empty?
      chain = create_processor_chain
      chain.each do |processor|
        tags_hash.merge! processor.process(tags_hash)
      end
    end

    protected

    def create_processor_chain
      chain = []
      chain << @object_factory.create_url_remover if @options[:removeurls]
      chain << @object_factory.create_tag_cleaner if @options[:cleantags]
      chain << @object_factory.create_tag_normalizer
      chain << @object_factory.create_tag_setter(@options)
      chain
    end

  end

end
