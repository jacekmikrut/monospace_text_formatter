require "spec_helper"

describe MonospaceTextFormatter::Line do

  describe 'MonospaceTextFormatter::Line.new("This is text.")' do
    subject { described_class.new("This is text.") }
    its(:width)      { should == 13              }
    its(:omission)   { should == " ..."          }
    its(:align)      { should == :left           }
    its(:fill)       { should == " "             }
    its(:truncated?) { should be_false           }
    its(:to_s)       { should == "This is text." }
    its(:inspect)    { should == %Q{#<MonospaceTextFormatter::Line "This is text.">} }
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

  describe "#omission=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.") }

    it "should update the width" do

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

    it "should update the width" do

      subject.to_s.should == "This is some text.   "

      subject.align = :center
      subject.to_s.should == " This is some text.  "

      subject.align = "right"
      subject.to_s.should == "   This is some text."

      subject.align = :left
      subject.to_s.should == "This is some text.   "
    end

    describe "#align= :middle" do
      it { lambda { subject.align = :middle }.should raise_error(ArgumentError, "The :align must be a Symbol or String with value 'left', 'center' or 'right', but is :middle") }
    end
  end

  describe "#fill=" do

    subject { MonospaceTextFormatter::Line.new("This is some text.", :width => 25) }

    it "should update the width" do

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
