require 'spec_helper'

RSpec.describe RSpec::ActiveJob::Matchers::GlobalID do
  class MyModel
    def to_global_id
      "gid://my-app/MyModel/ID123"
    end
  end

  let(:instance) { described_class.new(expected) }
  subject(:matches?) { instance === actual }

  before { GlobalID.app = 'my-app' }

  context "expecting a class" do
    let(:expected) { MyModel }

    context "serialized model" do
      let(:actual) { { '_aj_globalid' => 'gid://my-app/MyModel/ID123' } }
      it { is_expected.to be(true) }
    end

    context "actual model" do
      let(:actual) { MyModel.new }
      it { is_expected.to be(false) }
    end

    context "model class" do
      let(:actual) { MyModel }
      it { is_expected.to be(false) }
    end

    context "hash with extra stuff" do
      let(:actual) do
        { '_aj_globalid' => 'gid://my-app/MyModel/ID123', 'other' => 'stuff' }
      end
      it { is_expected.to be(false) }
    end

    context "invalid GlobalID" do
      let(:actual) { { '_aj_globalid' => 'not://a/global/id' } }
      it { is_expected.to be(false) }
    end

    context "nil" do
      let(:actual) { nil }
      it { is_expected.to be(false) }
    end
  end

  context "expecting a specific instance" do
    let(:expected) { MyModel.new }

    context "serialized instance" do
      let(:actual) { { '_aj_globalid' => 'gid://my-app/MyModel/ID123' } }
      it { is_expected.to be(true) }
    end

    context "model class" do
      let(:actual) { MyModel }
      it { is_expected.to be(false) }
    end

    context "instance itself" do
      let(:actual) { expected }
      it { is_expected.to be(false) }
    end

    context "hash with extra stuff" do
      let(:actual) do
        { '_aj_globalid' => 'gid://my-app/MyModel/ID123', 'other' => 'stuff' }
      end
      it { is_expected.to be(false) }
    end

    context "mismatching app" do
      let(:actual) { { '_aj_globalid' => 'gid://other-app/MyModel/ID123' } }
      it { is_expected.to be(false) }
    end

    context "mismatching model" do
      let(:actual) { { '_aj_globalid' => 'gid://my-app/OtherModel/ID123' } }
      it { is_expected.to be(false) }
    end

    context "mismatching ID" do
      let(:actual) { { '_aj_globalid' => 'gid://my-app/MyModel/ID456' } }
      it { is_expected.to be(false) }
    end
  end

  context "expecting a non-gid instance" do
    let(:expected) { Object.new }
    specify { expect { matches? }.to raise_error }
  end

  context "expecting a non-gid class" do
    let(:expected) { Object }
    specify { expect { matches? }.to raise_error }
  end
end
