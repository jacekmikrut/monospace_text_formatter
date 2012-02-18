module MonospaceTextFormatter
  class Line

    def initialize(string_or_chunk, attrs={})
         @omission = string_to_chunk(" ...")
            @align = :left
             @fill = " "
        @truncated = nil

      raise ArgumentError, "No string given" unless string_or_chunk
      @original_chunk = to_chunk_if_string(string_or_chunk)

      attributes(attrs)
    end

    attr_reader :omission, :align, :fill

    def width
      @fixed_width || visible_chunk.display_length
    end

    def attributes(attrs={})
      attrs.each { |name, value| send("#{name}=", value) }
    end

    def width=(fixed_width)
      return if fixed_width == @fixed_width
      raise ArgumentError, "The :width must be equal or greater than 0, but is #{fixed_width}" unless fixed_width.nil? or fixed_width >= 0

      @aligned_visible_text = @visible_chunk = nil
      @fixed_width = fixed_width
    end

    def omission=(omission)
      return if omission == @omission

      @aligned_visible_text = @visible_chunk = nil if @truncated
      @omission = to_chunk_if_string(omission)
    end

    def align=(align)
      return if align == @align
      raise ArgumentError, "The :align must be a Symbol or String with value 'left', 'center' or 'right', but is #{align.inspect}" unless [:left, :center, :right].include?(align.to_sym)

      @aligned_visible_text = nil
      @align = align.to_sym
    end

    def fill=(fill)
      return if fill == @fill

      @aligned_visible_text = nil
      @fill = fill
    end

    def truncated?
      visible_chunk
      @truncated
    end

    def to_s
      aligned_visible_text
    end

    def inspect
      %Q(#<#{self.class} #{to_s.inspect}>)
    end

    private

    def to_chunk_if_string(string)
      string.is_a?(String) ? string_to_chunk(string) : string
    end

    def string_to_chunk(string)
      Chunk.new(string)
    end

    def aligned_visible_text
      @aligned_visible_text ||= if @fixed_width.nil? or fill.nil? or fill.empty?
                                  visible_chunk.to_s
                                else
                                  case align
                                  when :left
                                    visible_chunk.to_s.ljust( @fixed_width + visible_chunk.non_display_length, fill)
                                  when :center
                                    visible_chunk.to_s.center(@fixed_width + visible_chunk.non_display_length, fill)
                                  when :right
                                    visible_chunk.to_s.rjust( @fixed_width + visible_chunk.non_display_length, fill)
                                  end
                                end
    end

    def visible_chunk
      @visible_chunk ||= if @original_chunk.multiline? || @fixed_width && @original_chunk.display_length > @fixed_width
                           @truncated = true
                           @original_chunk.slice(@fixed_width ? @fixed_width - omission.display_length : nil).concat(omission).slice!(@fixed_width)
                         else
                           @truncated = false
                           @original_chunk.slice(@fixed_width)
                         end
    end
  end
end
