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
      show_usage_and_exit if @options[:files].empty?
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

        opts.on(      "--renameformat [FORMAT]", "Rename processed files using this file name format.") do |format|
          @options[:renameformat] = format
        end

        opts.separator " "
        
        opts.on("-c", "--[no-]cleantags", "Clean up tags by removing artist and album from title for example.") do |cleantags|
          @options[:cleantags] = cleantags
        end
        opts.on("-e", "--[no-]errorstops", "Stop execution if an error occurs.") do |errorstops|
          @options[:errorstops] = errorstops
        end
        opts.on("-s", "--[no-]guess", "Use format guessing. Used only if no --format matched.") do |guess|
          @options[:guess] = guess
        end
        opts.on("-r", "--[no-]recurse", "Scan for files recursively.") do |recurse|
          @options[:recurse] = recurse
        end
        opts.on("-k", "--[no-]removetags", "Remove any existing v1 and v2 tags. This is an expensive and destructive operation.") do |removetags|
          @options[:removetags] = removetags
        end
        opts.on(      "--[no-]removeurls", "Remove URLs from file names.") do |removeurls|
          @options[:removeurls] = removeurls
        end
        opts.on("-u", "--[no-]replaceunderscores", "Replace underscores with spaces before processing a file name.") do |replaceunderscores|
          @options[:replaceunderscores] = replaceunderscores
        end
        opts.on("-w", "--[no-]showtags", "Show the resulting tags.") do |showtags|
          @options[:showtags] = showtags
        end
        opts.on("-v", "--[no-]verbose", "Print verbose messages about processing operations.") do |verbose|
          @options[:verbose] = verbose
        end

        opts.separator " "
        opts.separator "Informational options:"

        opts.on("--help-formats", "Show help on writing --format strings.") do
          show_available_tags_and_exit
        end
        opts.on("--list-formats", "List built-in formats used for guessing with --guess option.") do |list|
          show_known_formats_and_exit
        end
        opts.on("--version", "Show version information.") do |version|
          show_version_info_and_exit
        end

        opts.on_tail("--help", "Show this message") do
          show_usage_and_exit
        end
      end
    end

    def show_usage_and_exit
      puts @parser.to_s
      exit 1
    end

    def show_available_tags_and_exit
      print_taglist_header
      Tagomatic::Tags::AVAILABLE_TAGS.each do |tag|
        puts format_taglist_entry(tag)
      end
      exit 1
    end

    def show_known_formats_and_exit()
      puts Tagomatic::Tagger::KNOWN_FORMATS
      exit 1
    end

    def show_version_info_and_exit()
      puts File.read(File.join(File.dirname($0), '..', 'VERSION'))
      exit 1
    end

    def print_taglist_header
      puts TAGLIST_HEADER
      puts '-' * 60
    end

    def format_taglist_entry(tag)
      tag_info = tag.name
      tag_info << ':'
      tag_info << ' ' * (24 - tag_info.length)
      tag_info << '%'
      tag_info << tag.id
      tag_info << ' ' * 8
      tag_info << tag.regexp
      tag_info
    end

    TAGLIST_HEADER = "Tag Name" + (' ' * 16) + "ID" + (' ' * 8) + "Regular Expression"

  end

end
