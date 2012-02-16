require "spec_helper"

describe MonospaceTextFormatter::Box do

  describe 'MonospaceTextFormatter::Box.new("First line.\nSecond, a bit longer line.")' do
    subject { described_class.new("First line.\nSecond, a bit longer line.") }
    its(:width)      { should == 26     }
    its(:height)     { should ==  2     }
    its(:omission)   { should == " ..." }
    its(:align)      { should == :left  }
    its(:valign)     { should == :top   }
    its(:fill)       { should == " "    }
    its(:truncated?) { should be_false  }
    its(:to_s)       { should == "First line.               \nSecond, a bit longer line." }
  end

  describe "the text" do

    subject { described_class.new(string_or_chunk) }

    describe 'MonospaceTextFormatter::Box.new("This is some text.")' do
      let(:string_or_chunk) { "This is some text." }
      its(:width ) { should == 18 }
      its(:height) { should ==  1 }
      its(:lines ) { should == ["This is some text."] }
      its(:to_s  ) { should ==  "This is some text."  }
    end

    describe 'MonospaceTextFormatter::Box.new("  First line.  \n  Second line.  ")' do
      let(:string_or_chunk) { "  First line.  \n  Second line.  " }
      its(:width ) { should == 12 }
      its(:height) { should ==  2 }
      its(:lines ) { should == ["First line. ",
                               "Second line."] }
      its(:to_s  ) { should ==  "First line. \nSecond line."  }
    end

    describe 'MonospaceTextFormatter::Box.new("")' do
      let(:string_or_chunk) { "" }
      its(:width ) { should == 0 }
      its(:height) { should == 1 }
      its(:lines ) { should == [""] }
      its(:to_s  ) { should ==  ""  }
    end

    describe 'MonospaceTextFormatter::Box.new(MonospaceTextFormatter::Chunk.new("First line.\nSecond line."))' do
      let(:string_or_chunk) { MonospaceTextFormatter::Chunk.new("First line.\nSecond line.") }
      its(:width ) { should == 12 }
      its(:height) { should ==  2 }
      its(:lines ) { should == ["First line. ",
                               "Second line."] }
      its(:to_s  ) { should ==  "First line. \nSecond line."  }
    end

    describe 'MonospaceTextFormatter::Box.new(nil)' do
      let(:string_or_chunk) { nil }
      it { lambda { subject }.should raise_error(ArgumentError, "No string given") }
    end
  end

  describe "#attributes" do
    include_examples ":attributes method"
  end

  describe "#width=" do

    subject { MonospaceTextFormatter::Box.new(" First line.\n  And second, a bit longer line.") }

    it "should update the width" do

      subject.lines.should == ["First line.                   ",
                               "And second, a bit longer line."]

      subject.width = 14
      subject.lines.should == ["First line.   ",
                               "And second, a ",
                               "bit longer    ",
                               "line.         "]

      subject.width = 11
      subject.lines.should == ["First line.",
                               "And second,",
                               "a bit      ",
                               "longer     ",
                               "line.      "]

      subject.width = 3
      subject.lines.should == ["Fir",
                               "st ",
                               "lin",
                               "e. ",
                               "And",
                               "sec",
                               "ond",
                               ", a",
                               "bit",
                               "lon",
                               "ger",
                               "lin",
                               "e. "]

      subject.width = 0
      subject.lines.should == []

      subject.width = 0
      subject.height = 5
      subject.lines.should == ["",
                               "",
                               "",
                               "",
                               ""]
      subject.height = nil

      subject.width = nil
      subject.lines.should == ["First line.                   ",
                               "And second, a bit longer line."]
    end

    context "when setting width = -1" do
      it { lambda { subject.width = -1 }.should raise_error(ArgumentError, "The :width must be equal or greater than 0, but is -1") }
    end
  end

  describe "#height=" do

    subject { MonospaceTextFormatter::Box.new("First line.\nAnd second, a bit longer line.", :width => 17) }

    it "should update the height" do

      subject.lines.should == ["First line.      ",
                               "And second, a bit",
                               "longer line.     "]

      subject.height = 3
      subject.lines.should == ["First line.      ",
                               "And second, a bit",
                               "longer line.     "]

      subject.height = 2
      subject.lines.should == ["First line.      ",
                               "And second, a ..."]

      subject.height = 1
      subject.lines.should == ["First line. ...  "]

      subject.height = 0
      subject.lines.should == []

      subject.height = 4
      subject.lines.should == ["First line.      ",
                               "And second, a bit",
                               "longer line.     ",
                               "                 "]

      subject.height = nil
      subject.lines.should == ["First line.      ",
                               "And second, a bit",
                               "longer line.     "]
    end

    context "when setting height = -1" do
      it { lambda { subject.height = -1 }.should raise_error(ArgumentError, "The :height must be equal or greater than 0, but is -1") }
    end
  end

  describe "#omission=" do

    subject { MonospaceTextFormatter::Box.new("First line.\nAnd second, a bit longer line.", :width => 17, :height => 2) }

    it "should update the omission" do

      subject.lines.should == ["First line.      ",
                               "And second, a ..."]

      subject.omission = " [...]"
      subject.lines.should == ["First line.      ",
                               "And second, [...]"]

      subject.omission = MonospaceTextFormatter::Chunk.new(" (continued)")
      subject.lines.should == ["First line.      ",
                               "And (continued)  "]
    end
  end

  describe "#align=" do

    subject { MonospaceTextFormatter::Box.new("First line.\nAnd second, a bit longer line.", :width => 18) }

    it "should update the horizontal alignment" do

      subject.lines.should == ["First line.       ",
                               "And second, a bit ",
                               "longer line.      "]

      subject.align = :center
      subject.lines.should == ["   First line.    ",
                               "And second, a bit ",
                               "   longer line.   "]

      subject.align = 'right'
      subject.lines.should == ["       First line.",
                               " And second, a bit",
                               "      longer line."]

      subject.align = :left
      subject.lines.should == ["First line.       ",
                               "And second, a bit ",
                               "longer line.      "]
    end

    describe "when setting align = 'middle'" do
      it { lambda { subject.align = 'middle' }.should raise_error(ArgumentError, "The :align must be a Symbol or String with value 'left', 'center' or 'right', but is \"middle\"") }
    end
  end

  describe "#valign=" do

    subject { MonospaceTextFormatter::Box.new("First line.\nAnd second, a bit longer line.", :width => 17, :height => 6) }

    it "should update the vertical alignment" do

      subject.lines.should == ["First line.      ",
                               "And second, a bit",
                               "longer line.     ",
                               "                 ",
                               "                 ",
                               "                 "]

      subject.valign = :middle
      subject.lines.should == ["                 ",
                               "First line.      ",
                               "And second, a bit",
                               "longer line.     ",
                               "                 ",
                               "                 "]

      subject.valign = :bottom
      subject.lines.should == ["                 ",
                               "                 ",
                               "                 ",
                               "First line.      ",
                               "And second, a bit",
                               "longer line.     "]

      subject.valign = 'top'
      subject.lines.should == ["First line.      ",
                               "And second, a bit",
                               "longer line.     ",
                               "                 ",
                               "                 ",
                               "                 "]
    end

    describe "when setting valign = 'center'" do
      it { lambda { subject.valign = 'center' }.should raise_error(ArgumentError, "The :valign must be a Symbol or String with value 'top', 'middle' or 'bottom', but is \"center\"") }
    end
  end

  describe "#fill=" do

    subject { MonospaceTextFormatter::Box.new("First line.\nAnd second, a bit longer line.", :width => 18, :height => 6) }

    it "should update the fill" do

      subject.fill = "123"
      subject.lines.should == ["First line.1231231",
                               "And second, a bit1",
                               "longer line.123123",
                               "123123123123123123",
                               "123123123123123123",
                               "123123123123123123"]

      subject.align = :center
      subject.valign = :middle
      subject.lines.should == ["123123123123123123",
                               "123First line.1231",
                               "And second, a bit1",
                               "123longer line.123",
                               "123123123123123123",
                               "123123123123123123"]

      subject.align = :right
      subject.valign = :bottom
      subject.lines.should == ["123123123123123123",
                               "123123123123123123",
                               "123123123123123123",
                               "1231231First line.",
                               "1And second, a bit",
                               "123123longer line."]

      subject.fill = ""
      subject.lines.should == ["First line.",
                               "And second, a bit",
                               "longer line."]

      subject.fill = nil
      subject.lines.should == ["First line.",
                               "And second, a bit",
                               "longer line."]
    end
  end

  describe "#truncated?" do

    subject { MonospaceTextFormatter::Box.new("First line.\nAnd second, a bit longer line.") }

    it "should tell if the original text has been truncated" do

      subject.truncated?.should be_false

      subject.height = 1
      subject.truncated?.should be_true

      subject.height = 2
      subject.truncated?.should be_false

      subject.width = 15
      subject.truncated?.should be_true
    end
  end
end
