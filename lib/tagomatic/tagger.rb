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
            "%g/%a/%y %b/%n_-_%t.mp3",
            "%g/%a/%y %b/%n_%t.mp3",
            "%g/%a/%y %b/%n-%t.mp3",
            "%g/%a/%b [%y]/%n-%t.mp3",

            "%g/%a/%a_%b_%y/%n_%t.mp3",
            "%g/%a/%b [%y]/%n - %t.mp3",
            "%g/%a/%b/%a - %n - %t.mp3",
            "%g/%a/%b/%n - %t.mp3",
            "%g/%a/%b/%n-%t.mp3",
            "%g/%a/%b/%n_%t.mp3",
            "%g/%a/%b/%n %t.mp3",
            "%g/%a/%a- %b/%n %t.mp3",
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

      prepare_for_current_file(file_path)
      apply_known_formats
      apply_forced_tags
      try_updating_mp3file
    end

    protected

    def prepare_for_current_file(file_path)
      @file_path = file_path
      @tags = nil
    end

    def apply_known_formats
      apply_custom_formats if custom_formats_available?
      apply_known_formats if no_tags_set? and guessing_allowed?
    end

    def custom_formats_available?
      formats = @options[:formats]
      not (formats.nil? or formats.empty?)
    end

    def apply_custom_formats
      @tags = guess_tags_using(@options[:formats])
      show_error("no custom format matched #{@file_path}") unless @tags
    end

    def show_error(message)
      puts "ERROR: #{message}"
      exit 10 if @options[:errorstops]
    end

    def no_tags_set?
      @tags.nil? or @tags.empty?
    end

    def guessing_allowed?
      @options[:guess]
    end

    def apply_known_formats
      @tags = guess_tags_using(KNOWN_FORMATS)
      show_error("no format guess matched #{@file_path}") unless @tags
    end

    def guess_tags_using(formats)
      compile_if_necessary(formats)
      formats.each do |format|
        matched_tags = format.match(@file_path)
        return matched_tags unless matched_tags.nil? or matched_tags.empty?
      end
      nil
    end

    def compile_if_necessary(formats)
      formats.map! { |f| f.is_a?(FormatMatcher) ? f : @compiler.compile_format(f) }
    end

    def apply_forced_tags
      @tags ||= Hash.new
      @tags[:album] if @options[:album]
      @tags[:artist] if @options[:artist]
      @tags[:discnum] if @options[:discnum]
      @tags[:genre] if @options[:genre]
      @tags[:title] if @options[:title]
      @tags[:tracknum] if @options[:tracknum]
      @tags[:year] if @options[:year]
    end

    def try_updating_mp3file
      update_mp3file
    rescue
      @logger.error("failed updating #{@file_path}", $!)
    end

    def update_mp3file
      open_mp3file
      apply_tags
      close_mp3file
      # for some reasing mp3info will not write values if you read them before writing.
      # therefore the file has to be closed first, then reopened. note: the mp3info
      # reload method seems to be broken, too. obviously there is a good chance i simply
      # do not understand the mp3info api..
      open_mp3file
      show_mp3info if @options[:verbose]
      show_v1tags if @options[:showv1]
      show_v2tags if @options[:showv2]
    ensure
      close_mp3file
    end

    def open_mp3file
      @mp3 = @mp3info.open(@file_path)
    end

    def apply_tags
      updater = @info_updater_factory.create_info_updater(@mp3)

      discnum = @tags[FORMAT_ID_DISC]
      discnum_suffix = discnum ? " CD#{discnum}" : ''

      @tags.each do |tag, value|
        next unless tag and value
        next if tag == FORMAT_ID_IGNORE

        updater.album = value + discnum_suffix if tag == FORMAT_ID_ALBUM
        updater.artist = value if tag == FORMAT_ID_ARTIST
        updater.title = value if tag == FORMAT_ID_TITLE
        updater.tracknum = value.to_i if tag == FORMAT_ID_TRACKNUM
        updater.year = value if tag == FORMAT_ID_YEAR
      end

      updater.apply if updater.dirty?

      genre = @tags[FORMAT_ID_GENRE]
      if genre and @mp3.tag2.TCON.to_s != genre.to_s
        #info.tag.genre = genre DOES NOT WORK!
        @mp3.flush # this is required when using tag1/tag2 now after using the generic 'tag' above
        @mp3.tag1.genre = nil # we cannot set arbitrary values here. so we simply clear it.
        @mp3.tag2.TCON = genre
      end
    end

    def show_mp3info
      puts @mp3
    end

    def show_v1tags
      output = 'g='
      output << ( @mp3.tag1.genre || '<genre>' )
      output << '/a='
      output << ( @mp3.tag1.artist || '<artist>' )
      output << '/b='
      output << ( @mp3.tag1.album || '<album>' )
      output << '/y='
      output << ( @mp3.tag1.year ? "#{@mp3.tag1.year}" : '<year>' )
      output << '/n='
      output << ( @mp3.tag1.tracknum ? "#{@mp3.tag1.tracknum}" : '<tracknum>' )
      output << '/t='
      output << ( @mp3.tag1.title || '<title>' )
      puts output
    end

    def show_v2tags
      output = 'g='
      output << ( @mp3.tag2.TCON || '<genre>' )
      output << '/a='
      output << ( @mp3.tag2.TPE1 || '<artist>' )
      output << '/b='
      output << ( @mp3.tag2.TALB || '<album>' )
      output << '/y='
      output << ( @mp3.tag2.TYER ? "#{@mp3.tag2.TYER}" : '<year>' )
      output << '/n='
      output << ( @mp3.tag2.TRCK ? "#{@mp3.tag2.TRCK}" : '<tracknum>' )
      output << '/t='
      output << ( @mp3.tag2.TIT2 || '<title>' )
      puts output
    end

    def close_mp3file
      @mp3.close
    end

  end

end
