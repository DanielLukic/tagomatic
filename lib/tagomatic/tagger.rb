require 'fileutils'

require 'monkey/id3v2'
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
            "%g/%a/%b[%y]/%a-%b-%n-%t.mp3",
            "%g/%a/%b[%y]/%n-%t.mp3",
            "%g/%a/%b[%y]/%n%t.mp3",

            "%g/%a/%b(%y)/%a-%b-%n-%t.mp3",
            "%g/%a/%b(%y)/%n-%t.mp3",
            "%g/%a/%b(%y)/%n%t.mp3",

            "%g/%a/(%y)%b/%a-%b-%n-%t.mp3",
            "%g/%a/(%y)%b/%n-%t.mp3",
            "%g/%a/(%y)%b/%n%t.mp3",

            "%g/%a/%b/%n-%t.mp3",
            "%g/%a/%b/%n%t.mp3",

            "%g/%a/%b/%t.mp3",
            "%g/%a/%b/%t.MP3",
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
      replace_underscores if @options[:underscores]
      apply_formats
      apply_forced_tags
      try_updating_mp3file
    end

    protected

    def prepare_for_current_file(file_path)
      @file_path = file_path
      @tags = nil
    end

    def replace_underscores
      clean = @file_path.gsub('_', ' ')
      return if clean == @file_path
      @logger.verbose "renaming #{@file_path} to #{clean}"
      FileUtils.mv @file_path, clean
      @file_path = clean
    end

    def apply_formats
      apply_custom_formats if custom_formats_available?
      apply_known_formats if no_tags_set? and guessing_allowed?
    end

    def custom_formats_available?
      @options[:formats] and not @options[:formats].empty?
    end

    def apply_custom_formats
      @tags = guess_tags_using(@options[:formats])
      show_error("no custom format matched #{@file_path} using #{@options[:formats]}") unless @tags
    end

    def show_error(message, optional_exception = nil)
      @logger.error(message, optional_exception)
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
      show_error "failed updating #{@file_path}", $!
    end

    def update_mp3file
      open_mp3file
      clear_tags if @options[:cleartags]
      show_mp3info if @options[:verbose]
      apply_tags
      show_tags if @options[:showtags]
    ensure
      close_mp3file
    end

    def open_mp3file
      @mp3 = @mp3info.open(@file_path)
    end

    def clear_tags
      @mp3.removetag1
      @mp3.removetag2
    end

    def show_mp3info
      puts @mp3
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
        updater.genre_s = value if tag == FORMAT_ID_GENRE
        updater.title = value if tag == FORMAT_ID_TITLE
        updater.tracknum = value.to_i if tag == FORMAT_ID_TRACKNUM
        updater.year = value if tag == FORMAT_ID_YEAR
      end

      updater.apply if updater.dirty?
      puts "updated #{@file_path}" if updater.dirty?
    end

    def show_tags
      output = 'g='
      output << ( @mp3.tag.genre_s || '<genre>' )
      output << '/a='
      output << ( @mp3.tag.artist || '<artist>' )
      output << '/b='
      output << ( @mp3.tag.album || '<album>' )
      output << '/y='
      output << ( @mp3.tag.year ? "#{@mp3.tag.year}" : '<year>' )
      output << '/n='
      output << ( @mp3.tag.tracknum ? "#{@mp3.tag.tracknum}" : '<tracknum>' )
      output << '/t='
      output << ( @mp3.tag.title || '<title>' )
      puts output
    end

    def close_mp3file
      @mp3.close
    end

  end

end
