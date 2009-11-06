module Tagomatic

  class FormatParser

    attr_reader :prefix

    def initialize(format)
      @parts = format.split('%')
      @prefix = @parts.shift
    end

    def each_tag_and_tail(&block)
      @parts.each do |tag_and_tail|
        tag = tag_and_tail[0, 1]
        tail = tag_and_tail[1..-1]
        yield tag, tail
      end
    end

  end

end
