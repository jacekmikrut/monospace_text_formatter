require "spec_helper"

describe MonospaceTextFormatter::Chunk do

  describe "new instance" do

    context '.new()' do
      subject { described_class.new() }
      its(:multiline?    ) { should be_false }
      its(:blank?        ) { should be_true }
      its(:empty?        ) { should be_true }
      its(:display_length) { should == 0 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "" }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "">} }
    end

    context '.new("")' do
      subject { described_class.new("") }
      its(:multiline?    ) { should be_false }
      its(:blank?        ) { should be_true }
      its(:empty?        ) { should be_true }
      its(:display_length) { should == 0 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "" }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "">} }
    end

    context '.new("  ")' do
      subject { described_class.new("  ") }
      its(:multiline?    ) { should be_false }
      its(:blank?        ) { should be_true }
      its(:empty?        ) { should be_false }
      its(:display_length) { should == 2 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "  " }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "  ">} }
    end

    context '.new("\n")' do
      subject { described_class.new("\n") }
      its(:multiline?    ) { should be_true }
      its(:blank?        ) { should be_true }
      its(:empty?        ) { should be_false }
      its(:display_length) { should == 1 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "\n" }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "\\n">} }
    end

    context '.new("word")' do
      subject { described_class.new("word") }
      its(:multiline?    ) { should be_false }
      its(:blank?        ) { should be_false }
      its(:empty?        ) { should be_false }
      its(:display_length) { should == 4 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "word" }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "word">} }
    end

    context '.new("  word  ")' do
      subject { described_class.new("  word  ") }
      its(:multiline?    ) { should be_false }
      its(:blank?        ) { should be_false }
      its(:empty?        ) { should be_false }
      its(:display_length) { should == 8 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "  word  " }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "  word  ">} }
    end

    context '.new("This is some text.")' do
      subject { described_class.new("This is some text.") }
      its(:multiline?    ) { should be_false }
      its(:blank?        ) { should be_false }
      its(:empty?        ) { should be_false }
      its(:display_length) { should == 18 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "This is some text." }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "This is some text.">} }
    end

    context '.new("First line.\nSecond line.")' do
      subject { described_class.new("First line.\nSecond line.") }
      its(:multiline?    ) { should be_true }
      its(:blank?        ) { should be_false }
      its(:empty?        ) { should be_false }
      its(:display_length) { should == 24 }
      its(:non_display_length) { should == 0 }
      its(:to_s          ) { should == "First line.\nSecond line." }
      its(:inspect       ) { should == %Q{#<MonospaceTextFormatter::Chunk "First line.\\nSecond line.">} }
    end
  end

  describe "#duplicate" do

    it "should return instance of MonospaceTextFormatter::Chunk" do
      subject.duplicate.should be_a(MonospaceTextFormatter::Chunk)
    end

    describe "duplicated instance's @remaining_string variable" do

      it "should have the same content as the original one" do
        subject.duplicate.instance_variable_get("@remaining_string").should ==
          subject.instance_variable_get("@remaining_string")
      end

      it "should not be the same object as the original one" do
        subject.duplicate.instance_variable_get("@remaining_string").should_not equal(
          subject.instance_variable_get("@remaining_string"))
      end
    end

    describe "duplicated instance's @atomic_chunks variable" do

      it "should have the same content as the original one" do
        subject.duplicate.instance_variable_get("@atomic_chunks").should ==
          subject.instance_variable_get("@atomic_chunks")
      end

      it "should not be the same object as the original one" do
        subject.duplicate.instance_variable_get("@atomic_chunks").should_not equal(
          subject.instance_variable_get("@atomic_chunks"))
      end
    end
  end

  describe "#concat" do

    context 'MonospaceTextFormatter::Chunk.new("Some text.")' do
      let(:chunk) { described_class.new("Some text.") }

      context '.concat(" More text.")' do
        subject { chunk.concat(" More text.") }

        it("should return itself") { should equal(chunk) }
        it { should == "Some text. More text." }
      end

      context '.concat(MonospaceTextFormatter::Chunk.new(" More text."))' do
        subject { chunk.concat(described_class.new(" More text.")) }

        it("should return itself") { should equal(chunk) }
        it { should == "Some text. More text." }
      end
    end
  end

  describe "#+" do
    let(:duplicated_chunk) { stub(:duplicated_chunk) }
    let(:string_or_chunk ) { stub(:string_or_chunk ) }

    it "should return the result of #concat called on duplicated instance" do
      subject.should_receive(:duplicate).with(no_args).and_return(duplicated_chunk)
      duplicated_chunk.should_receive(:concat).with(string_or_chunk)

      subject + string_or_chunk
    end
  end

  describe "#slice!" do

    context 'MonospaceTextFormatter::Chunk.new("This is some text.")' do
      subject { described_class.new("This is some text.") }

      context ".slice!(0)" do
        it { subject.slice!(0).should == MonospaceTextFormatter::Chunk.new("") }
        describe "the remaining chunk" do
          it { subject.slice!(0); subject.should == MonospaceTextFormatter::Chunk.new("This is some text.") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("This is some text.")' do
      subject { described_class.new("This is some text.") }

      context ".slice!(7)" do
        it { subject.slice!(7).should == MonospaceTextFormatter::Chunk.new("This is") }
        describe "the remaining chunk" do
          it { subject.slice!(7); subject.should == MonospaceTextFormatter::Chunk.new(" some text.") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("This is some text.")' do
      subject { described_class.new("This is some text.") }

      context ".slice!(100)" do
        it { subject.slice!(100).should == MonospaceTextFormatter::Chunk.new("This is some text.") }
        describe "the remaining chunk" do
          it { subject.slice!(100); subject.should == MonospaceTextFormatter::Chunk.new("") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("First line.\nSecond line.")' do
      subject { described_class.new("First line.\nSecond line.") }

      context ".slice!" do
        it { subject.slice!(100).should == MonospaceTextFormatter::Chunk.new("First line.") }
        describe "the remaining chunk" do
          it { subject.slice!(100); subject.should == MonospaceTextFormatter::Chunk.new("Second line.") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("")' do
      subject { described_class.new("") }

      context ".slice!(10)" do
        it { subject.slice!(10).should == MonospaceTextFormatter::Chunk.new("") }
        describe "the remaining chunk" do
          it { subject.slice!(10); subject.should == MonospaceTextFormatter::Chunk.new("") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("  ")' do
      subject { described_class.new("  ") }

      context ".slice!(10)" do
        it { subject.slice!(10).should == MonospaceTextFormatter::Chunk.new("") }
        describe "the remaining chunk" do
          it { subject.slice!(10); subject.should == MonospaceTextFormatter::Chunk.new("") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("  Some text.")' do
      subject { described_class.new("  Some text.") }

      context ".slice!(10)" do
        it { subject.slice!(10).should == MonospaceTextFormatter::Chunk.new("Some text.") }
        describe "the remaining chunk" do
          it { subject.slice!(10); subject.should == MonospaceTextFormatter::Chunk.new("") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("Some  text.")' do
      subject { described_class.new("Some  text.") }

      context ".slice!(12)" do
        it { subject.slice!(12).should == MonospaceTextFormatter::Chunk.new("Some  text.") }
        describe "the remaining chunk" do
          it { subject.slice!(12); subject.should == MonospaceTextFormatter::Chunk.new("") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("Some text.   ")' do
      subject { described_class.new("Some text.   ") }

      context ".slice!(12)" do
        it { subject.slice!(12).should == MonospaceTextFormatter::Chunk.new("Some text.") }
        describe "the remaining chunk" do
          it { subject.slice!(12); subject.should == MonospaceTextFormatter::Chunk.new("   ") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("Some text.")' do
      subject { described_class.new("Some text.") }

      context ".slice!(5)" do
        it { subject.slice!(5).should == MonospaceTextFormatter::Chunk.new("Some") }
        describe "the remaining chunk" do
          it { subject.slice!(5); subject.should == MonospaceTextFormatter::Chunk.new("text.") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("Some text.")' do
      subject { described_class.new("Some text.") }

      context ".slice!" do
        it { subject.slice!.should == MonospaceTextFormatter::Chunk.new("Some text.") }
        describe "the remaining chunk" do
          it { subject.slice!; subject.should == MonospaceTextFormatter::Chunk.new("") }
        end
      end
    end

    context 'MonospaceTextFormatter::Chunk.new("First line.\nSecond line.")' do
      subject { described_class.new("First line.\nSecond line.") }

      context ".slice!" do
        it { subject.slice!.should == MonospaceTextFormatter::Chunk.new("First line.") }
        describe "the remaining chunk" do
          it { subject.slice!; subject.should == MonospaceTextFormatter::Chunk.new("Second line.") }
        end
      end
    end

    describe "splitting long words" do

      context 'MonospaceTextFormatter::Chunk.new("Here is averyverylongword.")' do
        subject { described_class.new("Here is averyverylongword.") }

        context ".slice!(12, true)" do
          it { subject.slice!(12, true).should == MonospaceTextFormatter::Chunk.new("Here is") }
          describe "the remaining chunk" do
            it { subject.slice!(12, true); subject.should == MonospaceTextFormatter::Chunk.new("averyverylongword.") }
          end
        end
      end

      context 'MonospaceTextFormatter::Chunk.new("Here is averyverylongword.")' do
        subject { described_class.new("Here is averyverylongword.") }

        context ".slice!(13, true)" do
          it { subject.slice!(13, true).should == MonospaceTextFormatter::Chunk.new("Here is avery") }
          describe "the remaining chunk" do
            it { subject.slice!(13, true); subject.should == MonospaceTextFormatter::Chunk.new("verylongword.") }
          end
        end
      end
    end
  end

  describe "#slice" do
    let(:duplicated_chunk   ) { stub(:duplicated_chunk  ) }
    let(:max_display_length ) { stub(:max_display_length) }

    it "should return the result of #slice! called on duplicated instance" do
      subject.should_receive(:duplicate).with(no_args).and_return(duplicated_chunk)
      duplicated_chunk.should_receive(:slice!).with(max_display_length)

      subject.slice(max_display_length)
    end
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
