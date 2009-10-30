#!/usr/bin/env ruby

require "rubygems"
require "mp3info"

require "optparse"
require "ostruct"

options = OpenStruct.new

options.files = []

options.album = nil
options.artist = nil
options.genre = nil
options.title = nil
options.tracknum = nil
options.year = nil

options.formats = []

options.guess = false
options.list = false
options.recurse = false
options.showv1 = false
options.showv2 = false
options.verbose = false

TAGS = %w(album,artist,genre,tracknum,title,year)

KNOWN_FORMATS = [
        "%g/%a/%a_%b_%y/%n_%t.mp3",
        "%g/%a/%b/%n - %t.mp3",
        "%g/%a/%b/%a - %t.mp3",
        "%g/%a/(%y) %b/%n - %t.mp3",
        "%g/%a/%y %b/%n - %t.mp3",
        "%a/%b/%n - %t.mp3",
        "%a - %y - %b/%n - %t.mp3",
        "%a - %b/%n - %t.mp3",
]

FORMAT_ID_ARTIST = 'a'
FORMAT_ID_ALBUM = 'b'
FORMAT_ID_GENRE = 'g'
FORMAT_ID_TITLE = 't'
FORMAT_ID_TRACKNUM = 'n'
FORMAT_ID_YEAR = 'y'

FORMAT_REGEXP_ARTIST = '(.+)'
FORMAT_REGEXP_ALBUM = '(.+)'
FORMAT_REGEXP_GENRE = '(.+)'
FORMAT_REGEXP_TITLE = '(.+)'
FORMAT_REGEXP_TRACKNUM = '([0-9]+)'
FORMAT_REGEXP_YEAR = '([0-9]+)'

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
      tags[@mapping[index]] = matchdata.captures[index]
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
    regexp << FORMAT_REGEXP_GENRE if tag == FORMAT_ID_GENRE
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

  opts.on("-f", "--format [FORMAT]", "Try applying this format string to determine tags. Multiple occurrences allowed.") do |format|
    options.formats << format
  end

  opts.on("-s", "--[no-]guess", "Use format guessing. Can be combined with --format.") do |guess|
    options.guess = guess
  end
  opts.on("-l", "--[no-]list", "List available formats for guessing.") do |list|
    options.list = list
  end
  opts.on("-r", "--[no-]recurse", "Scan for files recursively.") do |recurse|
    options.recurse = recurse
  end
  opts.on("-1", "--[no-]showv1", "Show the v1 tag values.") do |showv1|
    options.showv1 = showv1
  end
  opts.on("-2", "--[no-]showv2", "Show the v2 tag values.") do |showv2|
    options.showv2 = showv2
  end
  opts.on("-v", "--[no-]verbose", "Run verbosely.") do |verbose|
    options.verbose = verbose
  end

  opts.separator ""
  opts.separator "Common options:"

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

parser.parse! ARGV

files = ARGV

@options = options

puts KNOWN_FORMATS if @options.list

def guess_tags_for(file)
  KNOWN_FORMATS_COMPILED.each do |format|
    matched_tags = format.match file
    return matched_tags unless matched_tags.nil? or matched_tags.empty?
  end
  nil
end

def do_tagging_on(file)
  if @options.verbose
    puts "tagging #{file}"
    puts '=' * ( file.size + 8)
  end

  if @options.genre
    genres = Mp3Info::GENRES.select {|g| g.downcase == @options.genre.downcase }
    @genre_v1 = genres.size > 0 ? genres[0] : nil
  end

  if @options.guess
    matched_tags = guess_tags_for file

    if matched_tags
      Mp3Info.open(file) do |info|
        matched_tags.each do |tag, value|
          info.tag.album = value if tag == FORMAT_ID_ALBUM
          info.tag.artist = value if tag == FORMAT_ID_ARTIST
          info.tag.title = value if tag == FORMAT_ID_TITLE
          info.tag.tracknum = value if tag == FORMAT_ID_TRACKNUM
          info.tag.year = value if tag == FORMAT_ID_YEAR
          info.tag.album = value if tag == FORMAT_ID_ALBUM

          if tag == FORMAT_ID_GENRE
            genres = Mp3Info::GENRES.select {|g| g.downcase == value.downcase }
            genre_v1 = genres.size > 0 ? genres[0] : nil

            info.tag1.genre = genre_v1
            info.tag2.TCON = value
          end
        end
      end
    else
      puts "ERROR: failed guessing format for #{file}"
    end
  end

  Mp3Info.open(file) do |info|
    # TODO: Do this using the TAGS array..
    info.tag.album = @options.album if @options.album
    info.tag.artist = @options.artist if @options.artist
    info.tag.title = @options.title if @options.title
    info.tag.tracknum = @options.tracknum if @options.tracknum
    info.tag.year = @options.year if @options.year

    info.tag1.genre = @genre_v1 if @options.genre
    info.tag2.TCON = @options.genre if @options.genre
  end

  if @options.verbose
    Mp3Info.open(file) do |info|
      puts info
    end
  end

  if @options.showv1
    Mp3Info.open(file) do |info|
      output = ''
      output << ( info.tag1.genre || '<genre>' )
      output << '/'
      output << ( info.tag1.artist || '<artist>' )
      output << '/'
      output << ( info.tag1.album || '<album>' )
      output << '/'
      output << ( "#{info.tag1.year}" || '<year>' )
      output << '/'
      output << ( "#{info.tag1.tracknum}" || '<tracknum>' )
      output << '-'
      output << ( info.tag1.title || '<title>' )
      puts output
    end
  end
  if @options.showv2
    Mp3Info.open(file) do |info|
      output = ''
      output << ( info.tag2.TCON || '<genre>' )
      output << '/'
      output << ( info.tag2.TPE1 || '<artist>' )
      output << '/'
      output << ( info.tag2.TALB || '<album>' )
      output << '/'
      output << ( "#{info.tag2.TYER}" || '<year>' )
      output << '/'
      output << ( "#{info.tag2.TRCK}" || '<tracknum>' )
      output << '-'
      output << ( info.tag2.TIT2 || '<title>' )
      puts output
    end
  end
end

def scan(folder_path)
  entries = Dir.entries folder_path
  entries.each do |entry|
    next if entry == '.' || entry == '..'
    process folder_path, entry
  end
end

def process(path_prefix, file_or_folder)
  file_path = File.join path_prefix, file_or_folder
  puts "processing #{file_path}" if @options.verbose
  if File.file? file_path
    do_tagging_on file_path
  elsif File.directory? file_path
    scan file_path if @options.recurse
  end
end

files.each do |file|
  process '', file
end
