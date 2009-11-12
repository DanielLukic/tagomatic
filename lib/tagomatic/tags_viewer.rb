module Tagomatic

  class TagsViewer

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      return unless @options[:showtags]

      mp3 = tagger_context.mp3

      output = 'g='
      output << ( mp3.tag.genre_s || '<genre>' )
      output << '/a='
      output << ( mp3.tag.artist || '<artist>' )
      output << '/b='
      output << ( mp3.tag.album || '<album>' )
      output << '/y='
      output << ( mp3.tag.year ? "#{mp3.tag.year}" : '<year>' )
      output << '/n='
      output << ( mp3.tag.tracknum ? "#{mp3.tag.tracknum}" : '<tracknum>' )
      output << '/t='
      output << ( mp3.tag.title || '<title>' )
      puts output
    end

  end

end
