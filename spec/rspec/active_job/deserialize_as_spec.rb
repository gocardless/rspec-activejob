require 'spec_helper'

RSpec.describe RSpec::ActiveJob::Matchers::DeserializeAs do
  let(:instance) { described_class.new(expected) }
  subject(:matches?) { instance === actual }

  context "with an indifferent hash" do
    let(:actual) do
      { 'key' => 'value', '_aj_hash_with_indifferent_access' => true }
    end
    let(:expected) { ActiveSupport::HashWithIndifferentAccess.new(key: 'value') }

    it { is_expected.to be(true) }

    context "with a non-indifferent hash serialized" do
      let(:actual) { { 'key' => 'value', '_aj_symbol_keys' => [] } }

      it { is_expected.to be(false) }
    end
  end

  context "with a string-keyed hash" do
    let(:expected) { { 'key' => 'value' } }
    let(:actual) { { 'key' => 'value', '_aj_symbol_keys' => [] } }

    it { is_expected.to be(true) }

    context "with an indifferent hash serialized" do
      let(:actual) do
        { 'key' => 'value', '_aj_hash_with_indifferent_access' => true }
      end
      it { is_expected.to be(false) }
    end

    context "with a symbol keyed hash serialized" do
      let(:actual) { { 'key' => 'value', '_aj_symbol_keys' => ['key'] } }
      it { is_expected.to be(false) }
    end
  end

  context "with a symbol-keyed hash" do
    let(:expected) { { key: 'value' } }
    let(:actual) { { 'key' => 'value', '_aj_symbol_keys' => ['key'] } }

    it { is_expected.to be(true) }

    context "with an indifferent hash serialized" do
      let(:actual) do
        { 'key' => 'value', '_aj_hash_with_indifferent_access' => true }
      end
      it { is_expected.to be(false) }
    end

    context "with a string keyed hash serialized" do
      let(:actual) { { 'key' => 'value', '_aj_symbol_keys' => [] } }
      it { is_expected.to be(false) }
    end
  end
end
