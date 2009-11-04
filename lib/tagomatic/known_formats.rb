module Tagomatic

  module KnownFormats

    PREFIXES = [
            "%g/%a/%b-%y",
            "%g/%a/%b %Y",
            "%g/%a/%y-%b",
            "%g/%a/%Y %b",
            "%g/%a/%b",
            ]

    INFIXES = [
            "[disc%d]/",
            "[disk%d]/",
            "[cd%d]/",
            "(disc%d)/",
            "(disk%d)/",
            "(cd%d)/",
            " disc%d/",
            " disk%d/",
            " cd%d/",
            "/disc%d/",
            "/disk%d/",
            "/cd%d/",
            "/",
            ]

    SUFFIXES = [
            "%A-%B-%n-%t.mp3",
            "%B-%n-%t.mp3",
            "%A-%n-%t.mp3",
            "%n-%A-%t.mp3",
            "%n-%B-%t.mp3",
            "%n-%t.mp3",
            "%n.%t.mp3",
            "%n%t.mp3",
            "%t.mp3",
            ]

    def self.inflate_formats
      formats = []
      PREFIXES.each do |p|
        INFIXES.each do |i|
          SUFFIXES.each do |s|
            formats << (p + i + s)
          end
        end
      end
      formats
    end

    KNOWN_FORMATS = inflate_formats

  end

end
