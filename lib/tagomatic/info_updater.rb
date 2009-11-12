module Tagomatic

  class InfoUpdater

    def reset_to(mp3info)
      @info = mp3info
      @updates = {}
    end

    def apply
      @updates.each { |tag, value| write(tag, value) }
    end

    def dirty?
      @updates.each do |tag, value|
        current_value = read(tag).to_s
        return true if current_value != value.to_s
      end
      false
    end

    def album=(value)
      update :album, value
    end

    def artist=(value)
      update :artist, value
    end

    def genre_s=(value)
      update :genre_s, value
    end

    def title=(value)
      update :title, value
    end

    def tracknum=(value)
      update :tracknum, value
    end

    def year=(value)
      update :year, value
    end

    protected

    def update(tag, value)
      value.strip if value.respond_to?(:strip)
      @updates[tag] = value
    end

    def read(tag)
      @info.tag.send(tag)
    end

    def write(tag, value)
      @info.tag.send "#{tag}=".to_sym, value
    end

  end

end
