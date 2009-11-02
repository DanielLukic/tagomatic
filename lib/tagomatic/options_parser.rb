require 'optparse'

module Tagomatic

  class OptionsParser

    def initialize(options)
      @options = options
      @parser = create_parser
    end

    def parse!(arguments)
      @parser.parse!(arguments)
      @options[:files].concat(arguments)
    end

    def show_help
      @parser.to_s
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

        opts.on("-c", "--cleantags", "Clean up tags by removing artist and album from title for example.") do |cleantags|
          @options[:cleantags]= cleantags
        end
        opts.on("-k", "--cleartags", "Clear any existing v1 and v2 tags.") do |cleartags|
          @options[:cleartags]= cleartags
        end
        opts.on("-e", "--errorstops", "Stop execution if an error occurs.") do |errorstops|
          @options[:errorstops]= errorstops
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
        opts.on("-w", "--showtags", "Show the resulting tags.") do |showtags|
          @options[:showtags] = showtags
        end
        opts.on("-u", "--underscores", "Replace underscores with spaces before processing a file name.") do |underscores|
          @options[:underscores] = underscores
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
