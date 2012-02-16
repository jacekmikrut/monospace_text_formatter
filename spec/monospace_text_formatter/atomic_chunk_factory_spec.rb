require "spec_helper"

describe MonospaceTextFormatter::AtomicChunkFactory do

  describe "#new" do
    let(:string      ) { stub(:string      ) }
    let(:atomic_chunk) { stub(:atomic_chunk) }

    it "should return a new instance of MonospaceTextFormatter::AtomicChunk initialized with given string" do
      MonospaceTextFormatter::AtomicChunk.should_receive(:new).with(string).and_return(atomic_chunk)
      subject.new(string).should equal(atomic_chunk)
    end
  end

  describe "#slice_from!" do
    let(:result) { subject.slice_from!(string) }

    context 'called with "word"' do
      let(:string) { "word" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("word")) }
      describe("remaining string") { it { result; string.should == "" } }
    end

    context 'called with "word and another word"' do
      let(:string) { "word and another word" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("word")) }
      describe("remaining string") { it { result; string.should == " and another word" } }
    end

    context 'called with "word, another word"' do
      let(:string) { "word, another word" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("word,")) }
      describe("remaining string") { it { result; string.should == " another word" } }
    end

    context 'called with "word! another word"' do
      let(:string) { "word! another word" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("word!")) }
      describe("remaining string") { it { result; string.should == " another word" } }
    end

    context 'called with "one-word string?"' do
      let(:string) { "one-word string?" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("one-word")) }
      describe("remaining string") { it { result; string.should == " string?" } }
    end

    context 'called with "(a word)"' do
      let(:string) { "(a word)" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("(a")) }
      describe("remaining string") { it { result; string.should == " word)" } }
    end

    context 'called with "  word"' do
      let(:string) { "  word" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("  ")) }
      describe("remaining string") { it { result; string.should == "word" } }
    end

    context 'called with "\nword"' do
      let(:string) { "\nword" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("\n")) }
      describe("remaining string") { it { result; string.should == "word" } }
    end

    context 'called with "\t  \t word"' do
      let(:string) { "\t  \t word" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("\t  \t ")) }
      describe("remaining string") { it { result; string.should == "word" } }
    end

    context 'called with "<tag>some text</tag>"' do
      let(:string) { "<tag>some text</tag>" }
      it { result.should eq(MonospaceTextFormatter::AtomicChunk.new("<tag>some")) }
      describe("remaining string") { it { result; string.should == " text</tag>" } }
    end
  end

  describe "#slice_from" do
    let(:string           ) { stub(:string           ) }
    let(:duplicated_string) { stub(:duplicated_string) }
    let(:sliced_chunk     ) { stub(:sliced_chunk     ) }

    it "should return the result of #slice_from! called with duplicated string argument" do
      string.should_receive(:dup).with(no_args).and_return(duplicated_string)
      subject.should_receive(:slice_from!).with(duplicated_string).and_return(sliced_chunk)

      subject.slice_from(string)
    end
  end

  describe "#split_string" do
    let(:result) { subject.split_string(string, length) }

    context 'called with "string" and length 0' do
      let(:string) { "string" }
      let(:length) { 0 }
      it { result.should eq(
        [MonospaceTextFormatter::AtomicChunk.new(""), MonospaceTextFormatter::AtomicChunk.new("string")]
      ) }
      describe("remaining string") { it { result; string.should == "string" } }
    end

    context 'called with "string" and length 3' do
      let(:string) { "string" }
      let(:length) { 3 }
      it { result.should eq(
        [MonospaceTextFormatter::AtomicChunk.new("str"), MonospaceTextFormatter::AtomicChunk.new("ing")]
      ) }
      describe("remaining string") { it { result; string.should == "string" } }
    end

    context 'called with "string" and length 6' do
      let(:string) { "string" }
      let(:length) { 6 }
      it { result.should eq(
        [MonospaceTextFormatter::AtomicChunk.new("string"), MonospaceTextFormatter::AtomicChunk.new("")]
      ) }
      describe("remaining string") { it { result; string.should == "string" } }
    end

    context 'called with "string" and length 10' do
      let(:string) { "string" }
      let(:length) { 10 }
      it { result.should eq(
        [MonospaceTextFormatter::AtomicChunk.new("string"), MonospaceTextFormatter::AtomicChunk.new("")]
      ) }
      describe("remaining string") { it { result; string.should == "string" } }
    end
  end
end
