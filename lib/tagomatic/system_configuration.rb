require 'monkey/string'

module Tagomatic

  class SystemConfiguration < Hash

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    alias :super_method_missing :method_missing

    def method_missing(name, *arguments)
      handler = MetaHandler.new(self, name)
      handler.invoke(arguments)
    end

    def retrieve(key)
      key = key.to_sym
      self[key] || raise("global object #{key} not registered")
    end

    def register(assignment_hash)
      assignment_hash.each do |key, value|
        key = key.to_sym
        self[key] = value
      end
    end

    class MetaHandler

      def initialize(target, name)
        @target = target
        @name = name
      end

      def invoke(arguments)
        if is_calling?(:register)
          execute_invoke :register, arguments
        elsif is_calling?(:retrieve) or is_calling?(:get)
          execute_invoke :retrieve, arguments
        else
          raise "unsupported invocation: #{@name}"
        end
      end

      def is_calling?(method)
        @name.to_s.starts_with?("#{method}_")
      end

      def execute_invoke(method, arguments)
        key = extract_key
        full_arguments = [key] + arguments
        @target.send(method, *full_arguments)
      end

      def extract_key
        @name.to_s.sub(/^[^_]+_/, '')
      end

    end
  end

end
