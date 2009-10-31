#!/usr/bin/env ruby

require "rubygems"
require "mp3info"

require "optparse"
require "ostruct"

options = OpenStruct.new

options.files = []

options.album = nil
options.artist = nil
options.discnum = nil
options.genre = nil
options.title = nil
options.tracknum = nil
options.year = nil

options.formats = []

options.errorstops = false
options.guess = false
options.list = false
options.recurse = false
options.showv1 = false
options.showv2 = false
options.verbose = false

TAGS = %w(album,artist,genre,tracknum,title,year)

KNOWN_FORMATS = [
        "%g/VA/%i_-_%b-%y%i/%n_%a_-_%t.mp3",
        "%g/%a/%a.%b[P]%y(%i)/%n-%i-%i-%i- %t.mp3",
        "%g/%a/%a - %b [%i]/%n%t [%i].mp3",
        "%g/%a/%b/%a - %n - %t.mp3",
        "%g/%a/%b/%n - %i - %t.mp3",
        "%g/%a/%b/%n - %t.mp3",
        "%g/%a/%b/%n-%t.mp3",
        "%g/%a/%b/%n_%t.mp3",
        "%g/%a/%b/%n %t.mp3",
        "%g/%a/%b/%i %n - %i - %t.mp3",
        "%g/%a/%a- %b/%n %t.mp3",
        "%g/%a/%a_%b_%y/%n_%t.mp3",
        "%g/%a/%a-%b-%y-%i/%n-%i-%t.mp3",
        "%g/%a/%a-%b-%y-%i/%n-%t.mp3",
        "%g/%a/%b/%a - %t.mp3",
        "%g/%a/(%y) %b/%n - %t.mp3",
        "%g/%a/%y %b/%n - %t.mp3",
        "%a/%b/%n - %t.mp3",
        "%a - %y - %b/%n - %t.mp3",
        "%a - %b/%n - %t.mp3",
]

FORMAT_ID_ARTIST = 'a'
FORMAT_ID_ALBUM = 'b'
FORMAT_ID_DISC = 'd'
FORMAT_ID_GENRE = 'g'
FORMAT_ID_IGNORE = 'i'
FORMAT_ID_TITLE = 't'
FORMAT_ID_TRACKNUM = 'n'
FORMAT_ID_YEAR = 'y'

FORMAT_REGEXP_ARTIST = '([^\/]+)'
FORMAT_REGEXP_ALBUM = '([^\/]+)'
FORMAT_REGEXP_DISC = '([0-9]+)'
FORMAT_REGEXP_GENRE = '([^\/]+)'
FORMAT_REGEXP_IGNORE = '([^\/]+)'
FORMAT_REGEXP_TITLE = '([^\/]+)'
FORMAT_REGEXP_TRACKNUM = '([0-9]+)'
FORMAT_REGEXP_YEAR = '([0-9]+)'

LOCAL_CONFIG_FILE_NAME = '.tagomatic'

class FormatMatcher
  def initialize(compiled_regexp, tag_mapping, original_format)
    @regexp = compiled_regexp
    @mapping = tag_mapping
    @format = original_format
  end

  def match(file_path)
    matchdata = @regexp.match file_path
    return nil unless matchdata
    return nil unless matchdata.captures.size == @mapping.size
    tags = {}
    0.upto(@mapping.size) do |index|
      value = matchdata.captures[index]
      if value
        value = value.gsub '_', ' '
        parts = value.split ' '
        capitalized = parts.map {|p| p.capitalize}
        value = capitalized.join ' '
      end
      tags[@mapping[index]] = value
    end
    tags
  end

  def to_s
    @format
  end
end

def compile_format(format)
  parts = format.split '%'
  prefix = parts.shift
  tag_mapping = []
  regexp = Regexp.escape prefix
  parts.each do |tag_and_tail|
    tag = tag_and_tail[0, 1]
    tail = tag_and_tail[1..-1]
    tag_mapping << tag
    regexp << FORMAT_REGEXP_ALBUM if tag == FORMAT_ID_ALBUM
    regexp << FORMAT_REGEXP_ARTIST if tag == FORMAT_ID_ARTIST
    regexp << FORMAT_REGEXP_DISC if tag == FORMAT_ID_DISC
    regexp << FORMAT_REGEXP_GENRE if tag == FORMAT_ID_GENRE
    regexp << FORMAT_REGEXP_IGNORE if tag == FORMAT_ID_IGNORE
    regexp << FORMAT_REGEXP_TITLE if tag == FORMAT_ID_TITLE
    regexp << FORMAT_REGEXP_TRACKNUM if tag == FORMAT_ID_TRACKNUM
    regexp << FORMAT_REGEXP_YEAR if tag == FORMAT_ID_YEAR
    regexp << Regexp.escape(tail)
  end
  FormatMatcher.new Regexp.compile(regexp), tag_mapping, format
end

KNOWN_FORMATS_COMPILED = KNOWN_FORMATS.map {|f| compile_format f}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options..] files.."

  opts.separator ""
  opts.separator "Specific options:"

  # TODO: Generate these from the TAGS array..

  opts.on("-b", "--album [ALBUM]", "Set this album name.") do |album|
    options.album = album
  end
  opts.on("-a", "--artist [ARTIST]", "Set this artist name.") do |artist|
    options.artist = artist
  end
  opts.on("-d", "--discnum [DISCNUM]", "Disc number of a disc set. Will be appended to album.") do |discnum|
    options.discnum = discnum
  end
  opts.on("-g", "--genre [GENRE]", "Set this genre.") do |genre|
    options.genre = genre
  end
  opts.on("-t", "--title [TITLE]", "Set this title.") do |title|
    options.title = title
  end
  opts.on("-n", "--tracknum [TRACKNUMBER]", "Set this number.") do |tracknum|
    options.tracknum = tracknum
  end
  opts.on("-y", "--year [YEAR]", "Set this year/date.") do |year|
    options.year = year
  end

  opts.on("-f", "--format [FORMAT]", "Try applying this format string to determine tags. Multiple occurrences allowed. Last one is used first!") do |format|
    options.formats << compile_format(format)
  end

  opts.on("-e", "--errorstops", "Stop execution if an error occurs.") do |errorstops|
    options.errorstops = errorstops
  end
  opts.on("-s", "--guess", "Use format guessing. Can be combined with --format.") do |guess|
    options.guess = guess
  end
  opts.on("-l", "--list", "List available formats for guessing.") do |list|
    options.list = list
  end
  opts.on("-r", "--recurse", "Scan for files recursively.") do |recurse|
    options.recurse = recurse
  end
  opts.on("-1", "--showv1", "Show the v1 tag values.") do |showv1|
    options.showv1 = showv1
  end
  opts.on("-2", "--showv2", "Show the v2 tag values.") do |showv2|
    options.showv2 = showv2
  end

  opts.separator ""
  opts.separator "Common options:"

  opts.on("-v", "--verbose", "Run verbosely.") do |verbose|
    options.verbose = verbose
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

@parser = parser

parser.parse! ARGV

files = ARGV

@options = options

puts KNOWN_FORMATS if @options.list

def guess_tags_for(file, formats)
  formats.each do |format|
    matched_tags = format.match file
    return matched_tags unless matched_tags.nil? or matched_tags.empty?
  end
  nil
end

class InfoUpdater
  def initialize(mp3info)
    @info = mp3info
    @updates = {}
  end
  def apply
    @updates.each { |tag, value| write tag, value }
  end
  def dirty?
    @dirty
  end
  def album=(value)
    update :album, value
  end
  def artist=(value)
    update :artist, value
  end
  def title=(value)
    update :title, value
  end
  def tracknum=(value)
    update :tracknum, value
  end
  def year=(value)
    update :year, value
  end
  protected
  def update(tag, value)
    current_value = read(tag).to_s
    if current_value != value.to_s
      @updates[tag] = value
      @dirty = true
    end
  end
  def read(tag)
    @info.tag.send tag
  end
  def write(tag, value)
    @info.tag.send "#{tag}=".to_sym, value
  end
end

def apply_tags(file, tags_hash)
  Mp3Info.open(file) do |info|
    updater = InfoUpdater.new info

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
  exit 10 if @options.errorstops
end

def do_tagging_on(file)
  if @options.verbose
    puts "tagging #{file}"
    puts '=' * ( file.size + 8)
  end

  guess_if_allowed = true

  unless @options.formats.empty?
    matched_tags = guess_tags_for file, @options.formats
    apply_tags file, matched_tags if matched_tags
    guess_if_allowed = false if matched_tags
    show_error "no custom format matched #{file}" unless matched_tags
  end

  if guess_if_allowed and @options.guess
    matched_tags = guess_tags_for file, KNOWN_FORMATS_COMPILED
    apply_tags file, matched_tags if matched_tags
    show_error "no format guess matched #{file}" unless matched_tags
  end

  Mp3Info.open(file) do |info|
    # TODO: Do this using the TAGS array..
    info.tag.album = @options.album if @options.album
    info.tag.artist = @options.artist if @options.artist
    info.tag.title = @options.title if @options.title
    info.tag.tracknum = @options.tracknum if @options.tracknum
    info.tag.year = @options.year if @options.year

    info.tag1.genre = nil if @options.genre
    info.tag2.TCON = @options.genre if @options.genre
  end

  if @options.verbose
    Mp3Info.open(file) do |info|
      puts info
    end
  end

  if @options.showv1
    Mp3Info.open(file) do |info|
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
  if @options.showv2
    Mp3Info.open(file) do |info|
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

class String
  def starts_with?(prefix)
    pattern = Regexp.new "^#{Regexp.escape(prefix)}"
    pattern =~ self
  end
end

def scan_folder
  folder = @current_folder
  puts "scanning #{folder}" if @options.verbose
  entries = Dir.entries folder
  entries.each do |entry|
    next if entry == '.' or entry == '..' or entry.starts_with?('.format=')
    process folder, entry
  end
end

@options_stack = []

def save_current_options
  @options_stack << @options.dup
end

def determine_local_config_file_path
  File.join(@current_folder, LOCAL_CONFIG_FILE_NAME)
end

def has_local_config?
  File.exist? determine_local_config_file_path
end

def read_local_options
  argv = []
  lines = File.readlines determine_local_config_file_path
  lines.each do |line|
    matchdata = /(-{1,2}[^ ]+)( (.+))?/.match line
    next if matchdata.captures.size == 0
    argv << matchdata.captures[0]
    argv << matchdata.captures[2] if matchdata.captures.size == 3
  end
  @parser.parse! argv
end

def determine_local_formats_glob_pattern()
  "#{@current_folder}/.format=*"
end

def list_local_formats
  Dir.glob determine_local_formats_glob_pattern
end

def has_local_format?
  not list_local_formats.empty?
end

def read_local_format
  list_local_formats.each do |format_file_path|
    base_name = File.basename format_file_path
    format = base_name.sub '.format=', ''
    format.gsub! '|', '/'
    @options.formats << compile_format(format)
  end
end

def pop_local_options
  @options = @options_stack.pop
end

@current_folder = nil

def scan(folder_path)
  @current_folder = folder_path
  save_current_options
  read_local_options if has_local_config?
  read_local_format if has_local_format?
  scan_folder
  pop_local_options
end

def process(path_prefix, file_or_folder)
  file_path = File.join path_prefix, file_or_folder
  puts "processing #{file_path}" if @options.verbose
  if File.file? file_path and File.extname(file_path).downcase == '.mp3'
    do_tagging_on file_path
  elsif File.directory? file_path
    scan file_path if @options.recurse
  end
end

files.each do |file|
  process '', file
end
