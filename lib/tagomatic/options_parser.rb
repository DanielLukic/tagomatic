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

        opts.separator " "
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

        opts.separator " "
        opts.separator "Primary options:"

        opts.on("-f", "--format [FORMAT]", "Try applying this format string to determine tags. Multiple occurrences allowed.") do |format|
          @options[:formats] << format.gsub('|', '/')
        end

        opts.separator " "
        
        opts.on("-c", "--[no-]cleantags", "Clean up tags by removing artist and album from title for example.") do |cleantags|
          @options[:cleantags]= cleantags
        end
        opts.on("-k", "--[no-]cleartags", "Clear any existing v1 and v2 tags. This is an expensive and destructive operation.") do |cleartags|
          @options[:cleartags]= cleartags
        end
        opts.on("-e", "--[no-]errorstops", "Stop execution if an error occurs.") do |errorstops|
          @options[:errorstops]= errorstops
        end
        opts.on("-s", "--[no-]guess", "Use format guessing. Used only if no --format matched.") do |guess|
          @options[:guess] = guess
        end
        opts.on("-r", "--[no-]recurse", "Scan for files recursively.") do |recurse|
          @options[:recurse] = recurse
        end
        opts.on("-u", "--[no-]underscores", "Replace underscores with spaces before processing a file name.") do |underscores|
          @options[:underscores] = underscores
        end
        opts.on("-v", "--[no-]verbose", "Print verbose messages about processing operations.") do |verbose|
          @options[:verbose] = verbose
        end
        opts.on("-w", "--[no-]showtags", "Show the resulting tags.") do |showtags|
          @options[:showtags] = showtags
        end

        opts.separator " "
        opts.separator "Informational options:"

        opts.on("--help-formats", "Show help on writing --format strings.") do
          puts File.read(File.join(File.dirname($0), '..', 'lib/tagomatic/tags.rb'))
          exit
        end
        opts.on("--list-formats", "List built-in formats used for guessing with --guess option.") do |list|
          @options[:list] = list
        end
        opts.on("--version", "Show version information.") do |version|
          puts File.read(File.join(File.dirname($0), '..', 'VERSION'))
          exit
        end

        opts.on_tail("--help", "Show this message") do
          puts opts
          exit
        end
      end
    end

  end

end
