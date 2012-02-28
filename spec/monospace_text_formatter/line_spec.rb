require "spec_helper"

describe MonospaceTextFormatter::Line do

  describe 'MonospaceTextFormatter::Line.new("This is text.")' do
    subject { described_class.new("This is text.") }
    its(:width        ) { should == 13              }
    its(:padding_right) { should == 0               }
    its(:padding_left ) { should == 0               }
    its(:omission     ) { should == " ..."          }
    its(:align        ) { should == :left           }
    its(:fill         ) { should == " "             }
    its(:truncated?   ) { should be_false           }
    its(:to_s         ) { should == "This is text." }
    its(:inspect      ) { should == %Q{#<MonospaceTextFormatter::Line "This is text.">} }
  end

  describe "the text" do

    subject { described_class.new(string_or_chunk) }

    describe 'MonospaceTextFormatter::Line.new("This is some text.")' do
      let(:string_or_chunk) { "This is some text." }
      its(:to_s) { should == "This is some text." }
    end

    describe 'MonospaceTextFormatter::Line.new("  This is some text.  ")' do
      let(:string_or_chunk) { "  This is some text.  " }
      its(:to_s) { should == "This is some text." }
    end

    describe 'MonospaceTextFormatter::Line.new("")' do
      let(:string_or_chunk) { "" }
      its(:to_s) { should == "" }
    end

    describe 'MonospaceTextFormatter::Line.new("  ")' do
      let(:string_or_chunk) { "  " }
      its(:to_s) { should == "" }
    end

    describe 'MonospaceTextFormatter::Line.new(MonospaceTextFormatter::Chunk.new("This is some text."))' do
      let(:string_or_chunk) { MonospaceTextFormatter::Chunk.new("This is some text.") }
      its(:to_s) { should == "This is some text." }
    end

    describe 'MonospaceTextFormatter::Line.new(nil)' do
      let(:string_or_chunk) { nil }
      it { lambda { subject }.should raise_error(ArgumentError, "No string given") }
    end
  end

  describe "#attributes" do
    include_examples ":attributes method"
  end

  describe "#width=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.") }

    it "should update the width" do

      subject.width = 20
      subject.width.should == 20
      subject.to_s.should == "This is some text.  "

      subject.width = 18
      subject.width.should == 18
      subject.to_s.should == "This is some text."

      subject.width = 11
      subject.width.should == 11
      subject.to_s.should == "This is ..."

      subject.width = 0
      subject.width.should == 0
      subject.to_s.should == ""

      subject.width = nil
      subject.width.should == 18
      subject.to_s.should == "This is some text."
    end

    describe "#width = -1" do
      it { lambda { subject.width = -1 }.should raise_error(ArgumentError, "The :width must be equal or greater than 0, but is -1") }
    end
  end

  describe "#padding_right=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.") }

    it "should update the right padding" do

      subject.padding_right = 2
      subject.padding_right.should == 2
      subject.width.should == 20
      subject.to_s.should == "This is some text.  "

      subject.padding_right = 4
      subject.padding_right.should == 4
      subject.width.should == 22
      subject.to_s.should == "This is some text.    "
    end

    context "with fixed width" do

      subject { MonospaceTextFormatter::Line.new("This is some text.", :padding_right => 4) }

      it "should properly render the text" do

        subject.width = 20
        subject.to_s.should == "This is some ...    "

        subject.width = 12
        subject.to_s.should == "This ...    "

        subject.width = 3
        subject.to_s.should == "   "

        subject.width = 0
        subject.to_s.should == ""

        subject.width = nil
        subject.to_s.should == "This is some text.    "
      end
    end

    describe "#padding_right = -1" do
      it { lambda { subject.padding_right = -1 }.should raise_error(ArgumentError, "The :padding_right must be a number equal or greater than 0, but is -1") }
    end

    describe "#padding_right = nil" do
      it { lambda { subject.padding_right = nil }.should raise_error(ArgumentError, "The :padding_right must be a number equal or greater than 0, but is nil") }
    end
  end

  describe "#padding_left=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.") }

    it "should update the left padding" do

      subject.padding_left = 2
      subject.padding_left.should == 2
      subject.width.should == 20
      subject.to_s.should == "  This is some text."

      subject.padding_left = 4
      subject.padding_left.should == 4
      subject.width.should == 22
      subject.to_s.should == "    This is some text."
    end

    context "with fixed width" do

      subject { MonospaceTextFormatter::Line.new("This is some text.", :padding_left => 4) }

      it "should properly render the text" do

        subject.width = 20
        subject.to_s.should == "    This is some ..."

        subject.width = 12
        subject.to_s.should == "    This ..."

        subject.width = 3
        subject.to_s.should == "   "

        subject.width = 0
        subject.to_s.should == ""

        subject.width = nil
        subject.to_s.should == "    This is some text."
      end
    end

    describe "#padding_left = -1" do
      it { lambda { subject.padding_left = -1 }.should raise_error(ArgumentError, "The :padding_left must be a number equal or greater than 0, but is -1") }
    end

    describe "#padding_left = nil" do
      it { lambda { subject.padding_left = nil }.should raise_error(ArgumentError, "The :padding_left must be a number equal or greater than 0, but is nil") }
    end
  end

  describe "#omission=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.") }

    it "should update the omission" do

      subject.width = 15
      subject.to_s.should == "This is ...    "

      subject.omission = MonospaceTextFormatter::Chunk.new(" [...]")
      subject.to_s.should == "This is [...]  "

      subject.omission = ""
      subject.to_s.should == "This is some   "

      subject.omission = "123"
      subject.to_s.should == "This is some123"

      subject.width = 4
      subject.to_s.should == "T123"

      subject.width = 2
      subject.to_s.should == "12"

      subject.width = 1
      subject.to_s.should == "1"
    end
  end

  describe "#align=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.", :width => 21) }

    it "should update the alignment" do

      subject.to_s.should == "This is some text.   "

      subject.align = :center
      subject.to_s.should == " This is some text.  "

      subject.align = "right"
      subject.to_s.should == "   This is some text."

      subject.align = :left
      subject.to_s.should == "This is some text.   "
    end

    context "with padding" do
      subject { MonospaceTextFormatter::Line.new("This is some text.", :width => 25, :padding_right => 3, :padding_left => 1) }

      it "should update the alignment" do

        subject.to_s.should == " This is some text.      "

        subject.align = :center
        subject.to_s.should == "  This is some text.     "

        subject.align = "right"
        subject.to_s.should == "    This is some text.   "

        subject.align = :left
        subject.to_s.should == " This is some text.      "
      end
    end

    describe "#align= :middle" do
      it { lambda { subject.align = :middle }.should raise_error(ArgumentError, "The :align must be a Symbol or String with value 'left', 'center' or 'right', but is :middle") }
    end
  end

  describe "#fill=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.", :width => 25) }

    it "should update the fill" do

      subject.fill = "123"
      subject.to_s.should == "This is some text.1231231"

      subject.align = :center
      subject.to_s.should == "123This is some text.1231"

      subject.align = :right
      subject.to_s.should == "1231231This is some text."

      subject.fill = ""
      subject.to_s.should == "This is some text."

      subject.fill = nil
      subject.to_s.should == "This is some text."
    end

    context "with padding" do

      subject { MonospaceTextFormatter::Line.new("This is some text.", :width => 28, :padding_right => 1, :padding_left => 2) }

      it "should update the fill" do

        subject.fill = "123"

        subject.align = :left
        subject.to_s.should == "12This is some text.12312312"

        subject.align = :center
        subject.to_s.should == "12312This is some text.12312"

        subject.align = :right
        subject.to_s.should == "123123123This is some text.1"

        subject.fill = ""
        subject.to_s.should == "This is some text."

        subject.fill = nil
        subject.to_s.should == "This is some text."
      end
    end

    context "for empty content with width" do

      subject { MonospaceTextFormatter::Line.new("", :width => 10) }

      it "should update the fill" do

        subject.fill = "123"

        subject.align = :left
        subject.to_s.should == "1231231231"

        subject.align = :center
        subject.to_s.should == "1231231231"

        subject.align = :right
        subject.to_s.should == "1231231231"

        subject.fill = ""
        subject.to_s.should == ""

        subject.fill = nil
        subject.to_s.should == ""
      end
    end

    context "for empty content and with width and padding" do

      subject { MonospaceTextFormatter::Line.new("", :width => 10, :padding_left => 2, :padding_right => 2) }

      it "should update the fill" do

        subject.fill = "123"

        subject.align = :left
        subject.to_s.should == "1231231231"

        subject.align = :center
        subject.to_s.should == "1231231231"

        subject.align = :right
        subject.to_s.should == "1231231231"

        subject.fill = ""
        subject.to_s.should == ""

        subject.fill = nil
        subject.to_s.should == ""
      end
    end
  end

  describe "#truncated?" do

    subject { MonospaceTextFormatter::Line.new("This is some text.") }

    it "should tell if the original text has been truncated" do

      subject.truncated?.should be_false

      subject.width = 18
      subject.truncated?.should be_false

      subject.width = 11
      subject.truncated?.should be_true

      described_class.new("First line.\nSecond line.")
      subject.truncated?.should be_true
    end
  end
end
