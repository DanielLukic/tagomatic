module Tagomatic

  class TaggerException < StandardError

    def initialize(message, optional_cause = nil)
      super(message)
      @optional_cause = optional_cause
    end

    def message
      super_message = super
      return super_message unless has_useful_optional_cause?
      "%s (caused by %s)" % [super_message, @optional_cause.message]
    end

    def set_backtrace(backtrace)
      # this piece stolen from nestegg gem..
      if has_optional_cause?
        @optional_cause.backtrace.reverse.each do |line|
          if backtrace.last == line
            backtrace.pop
          else
            break
          end
        end
        backtrace << "cause: #{@optional_cause.class.name}: #{@optional_cause}"
        backtrace.concat @optional_cause.backtrace
      end
      super backtrace
    end

    protected

    def has_useful_optional_cause?
      @optional_cause and @optional_cause.message and not @optional_cause.message.empty?
    end

    def has_optional_cause?
      @optional_cause
    end

  end

end
