require 'optparse'

module Tagomatic

  class Options < Hash

    def initialize
      self[:cleantags] = false
      self[:files] = []
      self[:formats] = []
      self[:errorstops] = false
      self[:guess] = false
      self[:list] = false
      self[:recurse] = false
      self[:removetags] = false
      self[:removeurls] = false
      self[:replaceunderscores] = false
      self[:showtags] = false
      self[:verbose] = false
    end

  end

end
