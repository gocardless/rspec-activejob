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

  context "with a block" do
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

      specify do
        matches?
        expect(instance.failure_message_negated).
          to eq("expected to not enqueue a job")
      end

      context "when it enqueues the wrong job" do
        let(:job_class) { BJob }

        it { is_expected.to be(false) }
        specify do
          matches?
          expect(instance.failure_message).
            to eq("expected to enqueue a BJob, enqueued a AJob")
        end
      end

      context "when it enqueues the right job" do
        let(:job_class) { AJob }

        it { is_expected.to be(true) }
        specify do
          matches?
          expect(instance.failure_message_negated).
            to eq("expected to not enqueue a AJob, but enqueued a AJob with []")
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
        lambda do
          enqueued_jobs << { job: AJob, args: [BJob.new, { thing: 1, 'thing' => 2 }] }
        end
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

  context "with job class" do
    let(:instance) { described_class.new }
    subject(:matches?) { instance.matches?(job_class) }

    context "when nothing has been enqueued" do
      it { is_expected.to be(false) }
      specify do
        matches?
        expect(instance.failure_message).
          to eq("expected to enqueue a job, enqueued nothing")
      end
    end

    context "when something gets enqueued" do
      let(:enqueued_jobs) { [{ job: AJob, args: [] }] }

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
        let(:enqueued_jobs) { [{ job: AJob, args: [] }, { job: BJob, args: [] }] }
        it { is_expected.to be(true) }
      end

      context "with argument expectations" do
        let(:job_class) { AJob }
        let(:instance) { described_class.new.with(*arguments) }
        let(:arguments) { [instance_of(BJob), hash_including(thing: 1)] }
        let(:enqueued_jobs) do
          [{ job: AJob, args: [BJob.new, { thing: 1, 'thing' => 2 }] }]
        end
        it { is_expected.to be(true) }

        context "with mismatching arguments"do
          let(:enqueued_jobs) { [{ job: AJob, args: [] }] }
          it { is_expected.to be(false) }
          specify do
            matches?
            expect(instance.failure_message).
              to eq("expected to enqueue a AJob with #{arguments}, but enqueued with []")
          end
        end
      end
    end
  end
end
