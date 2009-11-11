module Tagomatic

  class ScannerChain

    def initialize
      @chain = []
    end

    def append(chain_component)
      @chain << chain_component
    end

    def process_file(file_path, &block)
      @chain.each do |component|
        component.process_file file_path, &block
        return unless component.continue_processing?(file_path)
      end
    end

    def method_missing(name, *args, &block)
      @chain.each { |component| component.send name, *args, &block }
    end

  end

end
