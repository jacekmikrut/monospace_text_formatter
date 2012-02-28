module MonospaceTextFormatter
  class Line

    def initialize(string_or_chunk, attrs={})
      @padding_left  = 0
      @padding_right = 0
           @omission = string_to_chunk(" ...")
              @align = :left
               @fill = " "
          @truncated = nil

      raise ArgumentError, "No string given" unless string_or_chunk
      @original_chunk = to_chunk_if_string(string_or_chunk)

      attributes(attrs)
    end

    attr_reader :padding_left, :padding_right, :omission, :align, :fill

    def width
      @fixed_width || padding_left + visible_chunk.display_length + padding_right
    end

    def attributes(attrs={})
      attrs.each { |name, value| send("#{name}=", value) }
    end

    def width=(fixed_width)
      return if fixed_width == @fixed_width
      raise ArgumentError, "The :width must be equal or greater than 0, but is #{fixed_width}" unless fixed_width.nil? or fixed_width >= 0

      @aligned_visible_text = @visible_chunk = @fixed_width_minus_padding = nil
      @fixed_width = fixed_width
    end

    def padding_left=(padding_left)
      return if padding_left == @padding_left
      raise ArgumentError, "The :padding_left must be a number equal or greater than 0, but is #{padding_left.inspect}" unless padding_left.kind_of?(Fixnum) && padding_left >= 0

      @aligned_visible_text = nil
      @visible_chunk = @fixed_width_minus_padding = nil if @fixed_width
      @padding_left = padding_left
    end

    def padding_right=(padding_right)
      return if padding_right == @padding_right
      raise ArgumentError, "The :padding_right must be a number equal or greater than 0, but is #{padding_right.inspect}" unless padding_right.kind_of?(Fixnum) && padding_right >= 0

      @aligned_visible_text = nil
      @visible_chunk = @fixed_width_minus_padding = nil if @fixed_width
      @padding_right = padding_right
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

    def fixed_width_minus_padding
      @fixed_width_minus_padding ||= @fixed_width && (@fixed_width - padding_left - padding_right)
    end

    def aligned_visible_text
      @aligned_visible_text ||= if fill.nil? or fill.empty?
                                  visible_chunk.to_s
                                else
                                  string = visible_chunk.to_s
                                  string
                                    .rjust(left_fill_length(visible_chunk.display_length) + string.length                                                  , fill)
                                    .ljust(left_fill_length(visible_chunk.display_length) + string.length + right_fill_length(visible_chunk.display_length), fill)
                                end
    end

    def left_fill_length(display_length)
      return 0 if fill.nil? or fill.empty?
      return @fixed_width || 0 if display_length == 0

      [padding_left +
        if @fixed_width
          case align
          when :left
            0
          when :center
            ((fixed_width_minus_padding - display_length) / 2.0).floor
          when :right
            fixed_width_minus_padding - display_length
          end
        else
          0
        end, @fixed_width && @fixed_width - display_length].compact.min
    end

    def right_fill_length(display_length)
      return 0 if fill.nil? or fill.empty?
      return 0 if display_length == 0

      [padding_right +
        if @fixed_width
          case align
          when :left
            fixed_width_minus_padding - display_length
          when :center
            ((fixed_width_minus_padding - display_length) / 2.0).ceil
          when :right
            0
          end
        else
          0
        end, @fixed_width && @fixed_width - display_length].compact.min
    end

    def visible_chunk
      @visible_chunk ||= if @original_chunk.multiline? || fixed_width_minus_padding && @original_chunk.display_length > fixed_width_minus_padding
                           @truncated = true
                           @original_chunk.slice(fixed_width_minus_padding ? fixed_width_minus_padding - omission.display_length : nil).concat(omission).slice!(fixed_width_minus_padding)
                         else
                           @truncated = false
                           @original_chunk.slice(fixed_width_minus_padding)
                         end
    end
  end
end
