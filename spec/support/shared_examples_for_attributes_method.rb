shared_examples_for ":attributes method" do

  subject { described_class.new("") }
  let(:attr_value_1) { stub(:attr_value_1) }
  let(:attr_value_2) { stub(:attr_value_2) }

  it "should set proper attributes" do
    subject.should_receive("attr_name_1=").with(attr_value_1)
    subject.should_receive("attr_name_2=").with(attr_value_2)
    subject.attributes(:attr_name_1 => attr_value_1, :attr_name_2 => attr_value_2)
  end
end
