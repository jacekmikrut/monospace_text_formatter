module MonospaceTextFormatter
  class AtomicChunk

    def initialize(string)
      @string = string
    end

    def display_string
      @display_string ||= @string
    end

    def display_length
      @display_length ||= display_string.length
    end

    def newline?
      @string == "\n"
    end

    def blank?
      @string.strip.empty?
    end

    def empty?
      @string.empty?
    end

    def to_s
      @string
    end

    def inspect
      %Q(#<#{self.class} #{to_s.inspect}>)
    end

    def ==(other)
      to_s == other.to_s
    end
  end
end
