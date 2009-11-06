module Tagomatic

  class Tag

    attr_reader :name, :id, :regexp

    def initialize(name, id, regexp)
      @name = name
      @id = id
      @regexp = regexp
    end

    def to_s
      @name
    end

  end

end
