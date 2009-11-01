require 'tagomatic/info_updater'

module Tagomatic

  class Tagger

    FORMAT_ID_ARTIST = 'a'
    FORMAT_ID_ALBUM = 'b'
    FORMAT_ID_DISC = 'd'
    FORMAT_ID_GENRE = 'g'
    FORMAT_ID_IGNORE = 'i'
    FORMAT_ID_TITLE = 't'
    FORMAT_ID_TRACKNUM = 'n'
    FORMAT_ID_YEAR = 'y'

    KNOWN_FORMATS = [
            "%g/%a/%a_%b_%y/%n_%t.mp3",
            "%g/VA/%i_-_%b-%y%i/%n_%a_-_%t.mp3",
            "%g/%a/%a.%b[P]%y(%i)/%n-%i-%i-%i- %t.mp3",
            "%g/%a/%a - %b [%i]/%n%t [%i].mp3",
            "%g/%a/%b [%y]/%n - %t.mp3",
            "%g/%a/%b/%a - %n - %t.mp3",
            "%g/%a/%b/%n - %i - %t.mp3",
            "%g/%a/%b/%n - %t.mp3",
            "%g/%a/%b/%n-%t.mp3",
            "%g/%a/%b/%n_%t.mp3",
            "%g/%a/%b/%n %t.mp3",
            "%g/%a/%b/%i %n - %i - %t.mp3",
            "%g/%a/%a- %b/%n %t.mp3",
            "%g/%a/%a-%b-%y-%i/%n-%i-%t.mp3",
            "%g/%a/%a-%b-%y-%i/%n-%t.mp3",
            "%g/%a/%b/%a - %t.mp3",
            "%g/%a/(%y) %b/%n - %t.mp3",
            "%g/%a/%y %b/%n - %t.mp3",
            "%a/%b/%n - %t.mp3",
            "%a - %y - %b/%n - %t.mp3",
            "%a - %b/%n - %t.mp3",
    ]

    def initialize(options, compiler, mp3info, info_updater_factory, logger)
      @options = options
      @compiler = compiler
      @mp3info = mp3info
      @info_updater_factory = info_updater_factory
      @logger = logger
    end

    def process!(file_path)
      @logger.verbose "tagging #{file_path}"

      guess_if_allowed = true

      unless @options[:formats].empty?
        matched_tags = guess_tags_for file_path, @options[:formats]
        apply_tags file_path, matched_tags if matched_tags
        guess_if_allowed = false if matched_tags
        show_error "no custom format matched #{file_path}" unless matched_tags
      end

      if guess_if_allowed and @options[:guess]
        matched_tags = guess_tags_for file_path, KNOWN_FORMATS
        apply_tags file_path, matched_tags if matched_tags
        show_error "no format guess matched #{file_path}" unless matched_tags
      end

      @mp3info.open(file_path) do |info|
        info.tag.album = @options[:album] if @options[:album]
        info.tag.artist = @options[:artist] if @options[:artist]
        info.tag.title = @options[:title] if @options[:title]
        info.tag.tracknum = @options[:tracknum] if @options[:tracknum]
        info.tag.year = @options[:year] if @options[:year]

        info.tag1.genre = nil if @options[:genre]
        info.tag2.TCON = @options[:genre] if @options[:genre]
      end

      if @options[:verbose]
        @mp3info.open(file_path) do |info|
          puts info
        end
      end

      if @options[:showv1]
        @mp3info.open(file_path) do |info|
          output = 'g='
          output << ( info.tag1.genre || '<genre>' )
          output << '/a='
          output << ( info.tag1.artist || '<artist>' )
          output << '/b='
          output << ( info.tag1.album || '<album>' )
          output << '/y='
          output << ( info.tag1.year ? "#{info.tag1.year}" : '<year>' )
          output << '/n='
          output << ( info.tag1.tracknum ? "#{info.tag1.tracknum}" : '<tracknum>' )
          output << '/t='
          output << ( info.tag1.title || '<title>' )
          puts output
        end
      end

      if @options[:showv2]
        @mp3info.open(file_path) do |info|
          output = 'g='
          output << ( info.tag2.TCON || '<genre>' )
          output << '/a='
          output << ( info.tag2.TPE1 || '<artist>' )
          output << '/b='
          output << ( info.tag2.TALB || '<album>' )
          output << '/y='
          output << ( info.tag2.TYER ? "#{info.tag2.TYER}" : '<year>' )
          output << '/n='
          output << ( info.tag2.TRCK ? "#{info.tag2.TRCK}" : '<tracknum>' )
          output << '/t='
          output << ( info.tag2.TIT2 || '<title>' )
          puts output
        end
      end
    end

    def guess_tags_for(file, formats)
      compile_if_necessary(formats)
      formats.each do |format|
        matched_tags = format.match file
        return matched_tags unless matched_tags.nil? or matched_tags.empty?
      end
      nil
    end

    def compile_if_necessary(formats)
      formats.map! { |f| f.is_a?(FormatMatcher) ? f : @compiler.compile_format(f) }
    end

    def apply_tags(file, tags_hash)
      @mp3info.open(file) do |info|
        updater = @info_updater_factory.create_info_updater(info)

        discnum = tags_hash[FORMAT_ID_DISC]
        discnum_suffix = discnum ? " CD#{discnum}" : ''

        tags_hash.each do |tag, value|
          next unless tag and value
          next if tag == FORMAT_ID_IGNORE

          updater.album = value + discnum_suffix if tag == FORMAT_ID_ALBUM
          updater.artist = value if tag == FORMAT_ID_ARTIST
          updater.title = value if tag == FORMAT_ID_TITLE
          updater.tracknum = value.to_i if tag == FORMAT_ID_TRACKNUM
          updater.year = value if tag == FORMAT_ID_YEAR
        end

        updater.apply if updater.dirty?

        genre = tags_hash[FORMAT_ID_GENRE]
        if genre and info.tag2.TCON.to_s != genre.to_s
          #info.tag.genre = genre DOES NOT WORK!
          info.flush # this is required when using tag1/tag2 now after using the generic 'tag' above
          info.tag1.genre = nil # we cannot set arbitrary values here. so we simply clear it.
          info.tag2.TCON = genre
        end
      end
    end

    def show_error(message)
      puts "ERROR: #{message}"
      exit 10 if @options[:errorstops]
    end

  end

end
