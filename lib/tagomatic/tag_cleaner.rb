module Tagomatic

  class TagCleaner

    def process(tags_hash)
      artist = tags_hash['a']
      artist = Regexp.compile("[ -]*#{Regexp.escape(artist)}[ -]*", Regexp::IGNORECASE) if artist

      album = tags_hash['b']
      album = album.sub(artist, '') if artist and album
      tags_hash['b'] = album unless album.nil? or album.empty?

      album = Regexp.compile("[ -]*#{Regexp.escape(album)}[ -]*", Regexp::IGNORECASE) if album

      title = tags_hash['t']
      title = title.sub(artist, '') if artist and title
      title = title.sub(album, '') if album and title
      tags_hash['t'] = title unless title.nil? or title.empty?

      tags_hash
    end

  end

end
