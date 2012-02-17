module MonospaceTextFormatter
  class Box

    def initialize(string_or_chunk, attrs={})
         @omission = string_to_chunk(" ...")
            @align = :left
           @valign = :top
             @fill = " "

      raise ArgumentError, "No string given" unless string_or_chunk
      @original_chunk = to_chunk_if_string(string_or_chunk)

      attributes(attrs)
    end

    attr_reader :omission, :align, :valign, :fill

    def width
      @fixed_width || content_lines.first && content_lines.first.width
    end

    def height
      @fixed_height || content_lines.size
    end

    def attributes(attrs={})
      attrs.each { |name, value| send("#{name}=", value) }
    end

    def width=(fixed_width)
      return if fixed_width == @fixed_width
      raise ArgumentError, "The :width must be equal or greater than 0, but is #{fixed_width}" unless fixed_width.nil? or fixed_width >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = @content_lines = @empty_bottom_lines = nil
      @fixed_width = fixed_width
    end

    def height=(fixed_height)
      return if fixed_height == @fixed_height
      raise ArgumentError, "The :height must be equal or greater than 0, but is #{fixed_height}" unless fixed_height.nil? or fixed_height >= 0

      @to_s = @lines = @aligned_all_lines = @all_lines = @empty_top_lines = @content_lines = @empty_bottom_lines = nil
      @fixed_height = fixed_height
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

    private

    def to_chunk_if_string(string)
      string.is_a?(String) ? string_to_chunk(string) : string
    end

    def string_to_chunk(string)
      Chunk.new(string)
    end

    def new_line(string, attrs={})
      Line.new(string, attrs)
    end

    def aligned_all_lines
      @aligned_all_lines ||= all_lines.each do |line|
        line.attributes(:align => align, :fill => fill, :width => width)
      end
    end

    def all_lines
      @all_lines ||= empty_top_lines + content_lines + empty_bottom_lines
    end

    def empty_top_lines
      @empty_top_lines ||= if @fixed_height && fill && !fill.empty?
                             case valign
                             when :top
                               []
                             when :middle
                               Array.new(((@fixed_height - content_lines.size) / 2.0).floor, new_line(""))
                             when :bottom
                               Array.new(@fixed_height - content_lines.size, new_line(""))
                             end
                           else
                             []
                           end
    end

    def empty_bottom_lines
      @empty_bottom_lines ||= if @fixed_height && fill && !fill.empty?
                                case valign
                                when :top
                                  Array.new(@fixed_height - content_lines.size, new_line(""))
                                when :middle
                                  Array.new(((@fixed_height - content_lines.size) / 2.0).ceil, new_line(""))
                                when :bottom
                                  []
                                end
                              else
                                []
                              end
    end

    def content_lines
      return @content_lines unless @content_lines.nil?
      return @content_lines = [] if @fixed_width == 0 && @fixed_height.nil?
      return @content_lines = [new_line("")] if @original_chunk.empty?

      @remaining_chunk = @original_chunk.duplicate
      @line_chunks = []

      until (@fixed_height && @line_chunks.size == @fixed_height) || @remaining_chunk.empty?
        @line_chunks << if @line_chunks.size + 1 == @fixed_height
                          @remaining_chunk
                        else
                          @remaining_chunk.slice!(@fixed_width ? @fixed_width : nil)
                        end
      end

      common_width = @fixed_width || @line_chunks.map { |chunk| chunk.display_length }.max
      @content_lines = @line_chunks.map { |chunk| new_line(chunk, :width => common_width, :omission => omission) }
    end
  end
end
