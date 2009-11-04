module Tagomatic

  class TagSetter

    def initialize(options)
      @options = options
    end

    def process(tags_hash)
      tags_hash[:a] if @options[:artist]
      tags_hash[:b] if @options[:album]
      tags_hash[:d] if @options[:discnum]
      tags_hash[:g] if @options[:genre]
      tags_hash[:n] if @options[:tracknum]
      tags_hash[:t] if @options[:title]
      tags_hash[:y] if @options[:year]
      tags_hash
    end

  end

end
