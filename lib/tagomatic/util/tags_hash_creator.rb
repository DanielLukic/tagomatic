module Tagomatic

  module Util

    class TagsHashCreator

      def initialize(mapping, matchdata)
        @mapping = mapping
        @matchdata = matchdata
      end

      def create_tags_hash
        tags = Hash.new
        0.upto(@mapping.size - 1) do |index|
          value = @matchdata.captures[index]
          value = normalize(value) if value
          tags[@mapping[index]] = value
        end
        tags
      end

      protected

      def normalize(value)
        value = value.gsub('_', ' ')
        parts = value.split(' ')
        downcased = parts.map {|p| p.downcase}
        downcased.join(' ')
      end

    end

  end

end
