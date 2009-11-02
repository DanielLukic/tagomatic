require 'optparse'

module Tagomatic

  class Options < Hash

    def initialize
      self[:cleantags] = false
      self[:cleartags] = false
      self[:files] = []
      self[:formats] = []
      self[:errorstops] = false
      self[:guess] = false
      self[:list] = false
      self[:recurse] = false
      self[:showtags] = false
      self[:underscores] = false
      self[:verbose] = false
    end

  end

end
