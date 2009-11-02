require 'rubygems'
require 'mp3info'
require 'mp3info/id3v2'

class ID3v2

  alias :original_decode_tag :decode_tag

  def decode_tag(name, raw_value)
    original_decode_tag name, raw_value
  rescue
    nil
  end

end
