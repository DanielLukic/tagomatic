require 'optparse'

module Tagomatic

  class Options < Hash

    def initialize
      self[:files] = []
      self[:formats] = []
      self[:errorstops] = false
      self[:guess] = false
      self[:list] = false
      self[:recurse] = false
      self[:showv1] = false
      self[:showv2] = false
      self[:verbose] = false
    end

  end

end
