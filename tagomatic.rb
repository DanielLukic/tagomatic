#!/usr/bin/env ruby

require "rubygems"
require "mp3info"

require "optparse"
require "ostruct"

@options = options = OpenStruct.new

options.files = []

options.album = nil
options.artist = nil
options.genre = nil
options.number = nil
options.title = nil
options.year = nil

options.formats = []

options.showv1 = false
options.showv2 = false
options.recurse = false
options.verbose = false

TAGS = %w(album,artist,genre,tracknum,title,year)

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

  opts.on("-f", "--format [FORMAT]", "Try applying this format string to determine tags.") do |format|
    options.formats << format
  end

  opts.on("-1", "--[no-]showv1", "Show the v1 tag values.") do |showv1|
    options.showv1 = showv1
  end
  opts.on("-2", "--[no-]showv2", "Show the v2 tag values.") do |showv2|
    options.showv2 = showv2
  end
  opts.on("-r", "--[no-]recurse", "Scan for files recursively.") do |recurse|
    options.recurse = recurse
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

options
files = ARGV

def do_tagging_on(file)
  if @options.verbose
    puts "tagging #{file}"
    puts '=' * ( file.size + 8)
  end

  genres = Mp3Info::GENRES.select {|g| g.downcase == @options.genre.downcase }
  genre_v1 = genres.size > 0 ? genres[0] : nil

  Mp3Info.open(file) do |info|
    # TODO: Do this using the TAGS array..
    info.tag.album = @options.album if @options.album
    info.tag.artist = @options.artist if @options.artist
    info.tag.title = @options.title if @options.title
    info.tag.tracknum = @options.tracknum if @options.tracknum
    info.tag.year = @options.year if @options.year

    info.tag1.genre = genre_v1 if @options.genre
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
