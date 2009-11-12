module Tagomatic

  class TaggerChain

    def initialize
      @chain = []
    end

    def append(component)
      @chain << component
    end

    def process(tagger_context)
      @chain.each { |component| component.process tagger_context }
    rescue
      tagger_context.show_error "tagging failed: #{$!.message}", $!
    end

  end

end
