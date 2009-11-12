module Tagomatic

  class TagsProcessingChain

    def initialize
      @chain = []
    end

    def append(processor_component)
      @chain << processor_component
    end

    def process!(tags_hash)
      return if tags_hash.nil? or tags_hash.empty?
      @chain.each do |processor|
        tags_hash.merge! processor.process(tags_hash)
      end
    end

  end

end
