require 'tagomatic/tagger_exception'
require 'tagomatic/tags'

module Tagomatic

  class FileRenamer

    include Tagomatic::Tags

    def initialize(options)
      @options = options
    end

    def process(tagger_context)
      target_format = @options[:renameformat]
      return unless target_format and not target_format.empty?

      @context = tagger_context

      target_name = target_format.gsub(/%[a-zA-Z]/) do |match|
        @tag_id = match[1,1]
        value = determine_tag_value
        normalized = normalize_tag_value(value)
      end

      target_name.gsub!(' ', '_')

      source_path = tagger_context.file_path
      folder_path = File.dirname(source_path)
      target_path = File.join(folder_path, target_name)

      puts "#{source_path} => #{target_name}"

      FileUtils.mv(source_path, target_path)
      tagger_context.file_path = target_path
    rescue
      raise Tagomatic::TaggerException.new("failed renaming #{tagger_context.file_path}", $!)
    end

    protected

    def determine_tag_value
      @tag = TAGS_BY_ID[@tag_id]
      known_value or mp3info_value
    end

    def known_value
      @context.tags[@tag]
    end

    def mp3info_value
      mp3_tag_id = MP3INFO_ID_BY_TAG[@tag]
      @context.mp3.tag.send(mp3_tag_id)
    end

    def normalize_tag_value(value)
      if @tag == TRACKNUM
        value = "%02d" % [value.to_i]
      else
        value
      end
    end

  end

end
