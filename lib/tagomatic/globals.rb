require 'monkey/string'

module Tagomatic

  class Globals < Hash

    alias :super_method_missing :method_missing

    def method_missing(name, *arguments)
      handler = MetaHandler.new name
      handler.invoke arguments
    rescue Exception
      name.to_s.starts_with?('register_')
    end

    def retrieve(key)
      self[key] || raise("global object #{key} not registered")
    end

    def register(assignment_hash)
      assignment_hash.each { |key, value| self[key] = value }
    end

    class MetaHandler

      def initialize(name)
        @name = name
      end

      def invoke(arguments)
        if is_calling?(:register)
          do_invoke :register, arguments
        elsif is_calling?(:retrieve) or is_calling?(:get)
          do_invoke :retrieve, arguments
        else
          raise "unsupported invocation: #{@name}"
        end
      end

      def is_calling?(target)
        @name.to_s.starts_with?("#{target}_")
      end

      def do_invoke(target, arguments)
        send target, arguments
      end

    end
  end

end
