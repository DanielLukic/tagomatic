require 'ostruct'

module Tagomatic

  class TaggerContext < OpenStruct

    def reset_to(file_path)
      self.input_file_path = file_path
      self.output_file_path = file_path
      self.tags = Hash.new
    end

  end

end
