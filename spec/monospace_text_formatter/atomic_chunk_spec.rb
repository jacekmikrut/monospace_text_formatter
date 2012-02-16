require "spec_helper"

describe MonospaceTextFormatter::AtomicChunk do

  context '.new("")' do
    subject { described_class.new("") }
    its(:display_string) { should == "" }
    its(:display_length) { should == 0 }
    its(:newline?      ) { should be_false }
    its(:blank?        ) { should be_true }
    its(:empty?        ) { should be_true }
    its(:to_s          ) { should == "" }
    its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::AtomicChunk "">} }
  end

  context '.new("  ")' do
    subject { described_class.new("  ") }
    its(:display_string) { should == "  " }
    its(:display_length) { should == 2 }
    its(:newline?      ) { should be_false }
    its(:blank?        ) { should be_true }
    its(:empty?        ) { should be_false }
    its(:to_s          ) { should == "  " }
    its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::AtomicChunk "  ">} }
  end

  context '.new("\n")' do
    subject { described_class.new("\n") }
    its(:display_string) { should == "\n" }
    its(:display_length) { should == 1 }
    its(:newline?      ) { should be_true }
    its(:blank?        ) { should be_true }
    its(:empty?        ) { should be_false }
    its(:to_s          ) { should == "\n" }
    its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::AtomicChunk "\\n">} }
  end

  context '.new("text\n")' do
    subject { described_class.new("text\n") }
    its(:display_string) { should == "text\n" }
    its(:display_length) { should == 5 }
    its(:newline?      ) { should be_false }
    its(:blank?        ) { should be_false }
    its(:empty?        ) { should be_false }
    its(:to_s          ) { should == "text\n" }
    its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::AtomicChunk "text\\n">} }
  end

  context '.new("some text")' do
    subject { described_class.new("some text") }
    its(:display_string) { should == "some text" }
    its(:display_length) { should == 9 }
    its(:newline?      ) { should be_false }
    its(:blank?        ) { should be_false }
    its(:empty?        ) { should be_false }
    its(:to_s          ) { should == "some text" }
    its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::AtomicChunk "some text">} }
  end

  describe "#==" do
    subject { described_class.new("string") }

    context "when self.to_s == other.to_s" do
      let(:other) { stub(:other, :to_s => "string") }
      it { (subject == other).should be_true }
    end

    context "when self.to_s != other.to_s" do
      let(:other) { stub(:other, :to_s => "other string") }
      it { (subject == other).should be_false }
    end
  end
end
