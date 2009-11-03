module Tagomatic

  module Tags

    # Use these like this on the command line:
    # --format "%g/%a/%b (%y)/%n - %t.mp3"
    #
    # Or use them like this in folder-specific .format= file names:
    # touch ".format=%g|%a|%b (%y)|%n - %t.mp3"
    #
    # Some more examples showing what you can do:
    #
    # * Using %i (ignore) to swallow trash after album name:
    #   --format "%g/%a/%b - %i - %y/%n - %t.mp3"
    #
    # * Specifying text to be skipped:
    #   --format "%g/%a/%b - encoded by noone - %y/%n - %t.mp3"

    FORMAT_ID_ARTIST = 'a'
    FORMAT_ID_ARTIST_AGAIN = 'A'
    FORMAT_ID_ALBUM = 'b'
    FORMAT_ID_ALBUM_AGAIN = 'B'
    FORMAT_ID_DISC = 'd'
    FORMAT_ID_GENRE = 'g'
    FORMAT_ID_IGNORE = 'i'
    FORMAT_ID_TRACKNUM = 'n'
    FORMAT_ID_TITLE = 't'
    FORMAT_ID_WHITESPACE = 's'
    FORMAT_ID_EXTENDED_WHITESPACE = 'S'
    FORMAT_ID_YEAR = 'y'

    FORMAT_REGEXP_ARTIST = '([^\/]+)'
    FORMAT_REGEXP_ARTIST_AGAIN = FORMAT_REGEXP_ARTIST
    FORMAT_REGEXP_ALBUM = '([^\/]+)'
    FORMAT_REGEXP_ALBUM_AGAIN = FORMAT_REGEXP_ALBUM
    FORMAT_REGEXP_DISC = '\s*([0-9]+)\s*'
    FORMAT_REGEXP_GENRE = '([^\/]+)'
    FORMAT_REGEXP_IGNORE = '([^\/]+)'
    FORMAT_REGEXP_TRACKNUM = '\s*([0-9]+)\s*'
    FORMAT_REGEXP_TITLE = '([^\/]+)'
    FORMAT_REGEXP_WHITESPACE = '\s*'
    FORMAT_REGEXP_EXTENDED_WHITESPACE = '[\s\-_\.]*'
    FORMAT_REGEXP_YEAR = '\s*([0-9]+)\s*'

  end

end
