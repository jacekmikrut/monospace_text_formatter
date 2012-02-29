module MonospaceTextFormatter
  class Box

    def initialize(string_or_chunk, attrs={})
      @padding_top    = 0
      @padding_right  = 0
      @padding_bottom = 0
      @padding_left   = 0

         @omission = string_to_chunk(" ...")
            @align = :left
           @valign = :top
             @fill = " "

      raise ArgumentError, "No string given" unless string_or_chunk
      @original_chunk = to_chunk_if_string(string_or_chunk)

      attributes(attrs)
    end

    attr_reader :padding_top, :padding_right, :padding_bottom, :padding_left
    attr_reader :omission, :align, :valign, :fill

    def width
      @fixed_width || content_lines.first && content_lines.first.width
    end

    def height
      @fixed_height || padding_top + content_lines.size + padding_bottom
    end

    def attributes(attrs={})
      attrs.each { |name, value| send("#{name}=", value) }
    end

    def width=(fixed_width)
      return if fixed_width == @fixed_width
      raise ArgumentError, "The :width must be equal or greater than 0, but is #{fixed_width}" unless fixed_width.nil? or fixed_width >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = @content_lines = @empty_bottom_lines = @fixed_width_minus_padding = nil
      @fixed_width = fixed_width
    end

    def height=(fixed_height)
      return if fixed_height == @fixed_height
      raise ArgumentError, "The :height must be equal or greater than 0, but is #{fixed_height}" unless fixed_height.nil? or fixed_height >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = @content_lines = @empty_bottom_lines = @fixed_height_minus_padding = nil
      @fixed_height = fixed_height
    end

    def padding_top=(padding_top)
      return if padding_top == @padding_top
      raise ArgumentError, "The :padding_top must be a number equal or greater than 0, but is #{padding_top.inspect}" unless padding_top.kind_of?(Fixnum) && padding_top >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = nil
      @content_lines = @empty_bottom_lines = @fixed_height_minus_padding = nil if @fixed_height
      @padding_top = padding_top
    end

    def padding_right=(padding_right)
      return if padding_right == @padding_right
      raise ArgumentError, "The :padding_right must be a number equal or greater than 0, but is #{padding_right.inspect}" unless padding_right.kind_of?(Fixnum) && padding_right >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @content_lines = nil
      @fixed_width_minus_padding = nil if @fixed_width
      @padding_right = padding_right
    end

    def padding_bottom=(padding_bottom)
      return if padding_bottom == @padding_bottom
      raise ArgumentError, "The :padding_bottom must be a number equal or greater than 0, but is #{padding_bottom.inspect}" unless padding_bottom.kind_of?(Fixnum) && padding_bottom >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_bottom_lines = nil
      @content_lines = @empty_top_lines = @fixed_height_minus_padding = nil if @fixed_height
      @padding_bottom = padding_bottom
    end

    def padding_left=(padding_left)
      return if padding_left == @padding_left
      raise ArgumentError, "The :padding_left must be a number equal or greater than 0, but is #{padding_left.inspect}" unless padding_left.kind_of?(Fixnum) && padding_left >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @content_lines = nil
      @fixed_width_minus_padding = nil if @fixed_width
      @padding_left = padding_left
    end

    def omission=(omission)
      return if omission == @omission

      @to_s = @lines = @aligned_all_lines = @all_lines = @content_lines = nil if @content_lines && truncated?
      @omission = to_chunk_if_string(omission)
    end

    def align=(align)
      return if align == @align
      raise ArgumentError, "The :align must be a Symbol or String with value 'left', 'center' or 'right', but is #{align.inspect}" unless [:left, :center, :right].include?(align.to_sym)

      @to_s = @lines = @aligned_all_lines = nil
      @align = align.to_sym
    end

    def valign=(valign)
      return if valign == @valign
      raise ArgumentError, "The :valign must be a Symbol or String with value 'top', 'middle' or 'bottom', but is #{valign.inspect}" unless [:top, :middle, :bottom].include?(valign.to_sym)

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = @empty_bottom_lines = nil
      @valign = valign.to_sym
    end

    def fill=(fill)
      return if fill == @fill

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = @empty_bottom_lines = nil
      @fill = fill
    end

    def truncated?
      content_lines.last && content_lines.last.truncated?
    end

    def lines
      @lines ||= aligned_all_lines.map { |aligned_line| aligned_line.to_s }
    end

    def to_s
      @to_s ||= lines.join("\n")
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

    def new_line(string_or_chunk, attrs={})
      Line.new(string_or_chunk, attrs)
    end

    def fixed_height_minus_padding
      @fixed_height_minus_padding ||= @fixed_height && (@fixed_height - padding_top - padding_bottom)
    end

    def fixed_width_minus_padding
      @fixed_width_minus_padding ||= @fixed_width && (@fixed_width - padding_left - padding_right)
    end

    def aligned_all_lines
      @aligned_all_lines ||= all_lines.each do |line|
        line.attributes(:align => align, :fill => fill, :width => width, :padding_left => padding_left, :padding_right => padding_right)
      end
    end

    def all_lines
      @all_lines ||= empty_top_lines + content_lines + empty_bottom_lines
    end

    def empty_top_lines
      @empty_top_lines ||= Array.new(empty_top_lines_number, new_line(""))
    end

    def empty_top_lines_number
      return 0 if fill.nil? or fill.empty?

      [[padding_top +
        if @fixed_height
          case valign
          when :top
            0
          when :middle
            ((fixed_height_minus_padding - content_lines.size) / 2.0).floor
          when :bottom
            fixed_height_minus_padding - content_lines.size
          end
        else
          0
        end, @fixed_height && @fixed_height - content_lines.size].compact.min, 0].max
    end

    def empty_bottom_lines
      @empty_bottom_lines ||= Array.new(empty_bottom_lines_number, new_line(""))
    end

    def empty_bottom_lines_number
      return 0 if fill.nil? or fill.empty?

      [[padding_bottom +
        if @fixed_height
          case valign
          when :top
            fixed_height_minus_padding - content_lines.size
          when :middle
            ((fixed_height_minus_padding - content_lines.size) / 2.0).ceil
          when :bottom
            0
          end
        else
          0
        end, @fixed_height && @fixed_height - content_lines.size].compact.min, 0].max
    end

    def content_lines
      return @content_lines unless @content_lines.nil?
      return @content_lines = [] if fixed_width_minus_padding && fixed_width_minus_padding <= 0 && fixed_height_minus_padding.nil?
      return @content_lines = [new_line("")] if @original_chunk.empty?

      @remaining_chunk = @original_chunk.duplicate
      @line_chunks = []

      until (fixed_height_minus_padding && @line_chunks.size >= fixed_height_minus_padding) || @remaining_chunk.empty?
        @line_chunks << if @line_chunks.size + 1 == fixed_height_minus_padding
                          @remaining_chunk
                        else
                          @remaining_chunk.slice!(fixed_width_minus_padding ? [fixed_width_minus_padding, 0].max : nil)
                        end
      end

      @content_lines = @line_chunks.map { |chunk| new_line(chunk, :omission => omission, :padding_left => padding_left, :padding_right => padding_right) }
      common_width = @fixed_width || @content_lines.map { |line| line.width }.max
      @content_lines.each { |line| line.width = common_width }
    end
  end
end
