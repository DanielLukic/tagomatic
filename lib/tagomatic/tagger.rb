module Tagomatic

  class Tagger

    def initialize(tagger_context, tagger_chain, logger)
      @tagger_context = tagger_context
      @tagger_chain = tagger_chain
      @logger = logger
    end

    def process!(file_path)
      @logger.verbose "tagging #{file_path}"
      @tagger_context.reset_to file_path
      @tagger_chain.process @tagger_context
    end

  end

end
