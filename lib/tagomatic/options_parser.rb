require 'optparse'

module Tagomatic

  class OptionsParser

    def initialize(options)
      @options = options
      @parser = create_parser
    end

    def parse!(arguments)
      @parser.parse!(arguments)
      @options[:files].concat arguments
    end

    protected

    def create_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options..] files.."

        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-b", "--album [ALBUM]", "Set this album name.") do |album|
          @options[:album] = album
        end
        opts.on("-a", "--artist [ARTIST]", "Set this artist name.") do |artist|
          @options[:artist] = artist
        end
        opts.on("-d", "--discnum [DISCNUM]", "Set disc number of a disc set. Will be appended to album.") do |discnum|
          @options[:discnum] = discnum
        end
        opts.on("-g", "--genre [GENRE]", "Set this genre.") do |genre|
          @options[:genre] = genre
        end
        opts.on("-t", "--title [TITLE]", "Set this title.") do |title|
          @options[:title] = title
        end
        opts.on("-n", "--tracknum [TRACKNUMBER]", "Set this number.") do |tracknum|
          @options[:tracknum] = tracknum
        end
        opts.on("-y", "--year [YEAR]", "Set this year/date.") do |year|
          @options[:year] = year
        end

        opts.on("-f", "--format [FORMAT]", "Try applying this format string to determine tags. Multiple occurrences allowed.") do |format|
          @options[:formats] << format
        end

        opts.on("-e", "--errorstops", "Stop execution if an error occurs.") do |errorstops|
          @options[:errorstops ]= errorstops
        end
        opts.on("-s", "--guess", "Use format guessing. Can be combined with --format.") do |guess|
          @options[:guess] = guess
        end
        opts.on("-l", "--list", "List available formats for guessing.") do |list|
          @options[:list] = list
        end
        opts.on("-r", "--recurse", "Scan for files recursively.") do |recurse|
          @options[:recurse] = recurse
        end
        opts.on("-1", "--showv1", "Show the v1 tag values.") do |showv1|
          @options[:showv1] = showv1
        end
        opts.on("-2", "--showv2", "Show the v2 tag values.") do |showv2|
          @options[:showv2] = showv2
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on("-v", "--verbose", "Run verbosely.") do |verbose|
          @options[:verbose] = verbose
        end
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
    end

  end

end
