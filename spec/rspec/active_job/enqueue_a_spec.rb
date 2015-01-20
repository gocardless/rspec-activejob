require 'spec_helper'

RSpec.describe RSpec::ActiveJob::Matchers::EnqueueA do
  class AJob; end
  class BJob; end
  let(:enqueued_jobs) { [] }
  before do
    allow(::ActiveJob::Base).
      to receive(:queue_adapter).and_return(double(enqueued_jobs: enqueued_jobs))
  end

  let(:job_class) { nil }
  let(:instance) { described_class.new(job_class) }
  subject(:matches?) { instance.matches?(proc) }

  context "when nothing gets enqueued" do
    let(:proc) { -> {} }
    it { is_expected.to be(false) }
    specify do
      matches?
      expect(instance.failure_message).
        to eq("expected to enqueue a job, enqueued nothing")
    end
  end

  context "when something gets enqueued" do
    let(:proc) { -> { enqueued_jobs << { job: AJob, args: [] } } }

    it { is_expected.to be(true) }

    context "when it enqueues the wrong job" do
      let(:job_class) { BJob }

      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).
          to eq("expected to enqueue a BJob, enqueued a AJob")
      end
    end

    context "when it enqueues two jobs" do
      let(:proc) do
        -> { enqueued_jobs << { job: AJob, args: [] } << { job: BJob, args: [] } }
      end

      it { is_expected.to be(true) }
    end
  end

  context "with argument expectations" do
    let(:job_class) { AJob }
    let(:instance) { described_class.new(job_class).with(*arguments) }
    let(:arguments) { [instance_of(BJob), hash_including(thing: 1)] }

    let(:proc) do
      -> { enqueued_jobs << { job: AJob, args: [BJob.new, { thing: 1, 'thing' => 2 }] } }
    end

    it { is_expected.to be(true) }

    context "with mismatching arguments" do
      let(:proc) { -> { enqueued_jobs << { job: AJob, args: [] } } }

      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).
          to eq("expected to enqueue a AJob with #{arguments}, but enqueued with []")
      end
    end
  end
end
