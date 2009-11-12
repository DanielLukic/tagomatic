require 'fileutils'

require 'monkey/id3v2'
require 'tagomatic/info_updater'
require 'tagomatic/known_formats'
require 'tagomatic/tags'

module Tagomatic

  class Tagger

    include Tagomatic::Tags
    include Tagomatic::KnownFormats

    def initialize(options, compiler, tags_processor_chain, mp3info, object_factory, logger)
      @options = options
      @compiler = compiler
      @tags_processor_chain = tags_processor_chain
      @mp3info = mp3info
      @object_factory = object_factory
      @logger = logger
    end

    def process!(file_path)
      @logger.verbose "tagging #{file_path}"

      prepare_for_current_file(file_path)
      replace_underscores if @options[:underscores]
      apply_formats
      run_processor_chain
      try_updating_mp3file
    end

    protected

    def prepare_for_current_file(file_path)
      @file_path = file_path
      @tags = nil
    end

    def replace_underscores
      folder_path = File.dirname(@file_path)
      file_name = File.basename(@file_path)
      clean = file_name.gsub('_', ' ')
      return if clean == file_name
      @logger.verbose "renaming #{file_name} to #{clean}"
      quoted_source = escape_file_name(file_name)
      quoted_destination = escape_file_name(clean)
      system %Q[cd "#{folder_path}" && mv "#{quoted_source}" "#{quoted_destination}"] or return
      @file_path = File.join(folder_path, clean)
    end

    def escape_file_name(file_name)
      file_name.sub('"', '\"').sub('\'', '\\\'').sub('`', '\`')
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

    def run_processor_chain
      @tags ||= Hash.new
      @tags_processor_chain.process!(@tags)
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
      try_closing_mp3file
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
      updater = @object_factory.create_info_updater(@mp3)

      discnum = @tags[DISCNUM]
      discnum_suffix = discnum ? " CD#{discnum}" : ''

      @tags.each do |tag, value|
        next unless tag and value
        next if tag == IGNORE

        updater.album = value + discnum_suffix if tag == ALBUM
        updater.artist = value if tag == ARTIST
        updater.genre_s = value if tag == GENRE
        updater.title = value if tag == TITLE
        updater.tracknum = value.to_i if tag == TRACKNUM
        updater.year = value if tag == YEAR
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

    def try_closing_mp3file
      close_mp3file
    rescue
      show_error "failed closing #{@file_path} - file probably not updated", $!
    end

    def close_mp3file
      @mp3.close
    end

  end

end