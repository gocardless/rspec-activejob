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
        expect(instance.failure_message_when_negated).
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
          expect(instance.failure_message_when_negated).
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

        context "matches first job" do
          let(:job_class) { AJob }
          it { is_expected.to be(true) }
        end

        context "matches second job" do
          let(:job_class) { BJob }
          it { is_expected.to be(true) }
        end
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

  context "with run time expectations" do
    let(:instance) { described_class.new }
    let(:run_time) { Time.parse('2015-09-10 00:00:00 UTC').to_f }
    subject(:matches?) { instance.to_run_at(run_time).matches?(AJob) }

    let(:enqueued_jobs) do
      [{ job: AJob, args: [], at: time }]
    end

    context "correct time" do
      let(:time) { run_time }
      it { is_expected.to be(true) }
    end

    context "wrong time" do
      let(:time) { run_time + 1 }
      it { is_expected.to be(false) }

      specify do
        matches?
        expect(instance.failure_message).
          to eq("expected to run job at 2015-09-10 00:00:00 UTC, " \
            "but enqueued to run at 2015-09-10 00:00:01 UTC")
      end
    end
  end

  context "with number of times expectations" do
    let(:instance) { described_class.new }

    context "once" do
      subject(:matches?) { instance.once.matches?(AJob) }

      context "correct number of times" do
        context "as the only job" do
          let(:enqueued_jobs) { [{ job: AJob, args: [] }] }

          it { is_expected.to be(true) }
        end

        context "with other jobs" do
          let(:enqueued_jobs) { [{ job: AJob, args: [] }, { job: BJob, args: [] }] }

          it { is_expected.to be(true) }
        end
      end

      context "wrong number of times" do
        let(:enqueued_jobs) do
          [{ job: AJob, args: [] }, { job: AJob, args: [] }]
        end

        it { is_expected.to be(false) }

        specify do
          matches?
          expect(instance.failure_message).
            to eq("expected to enqueue a AJob once, but enqueued 2 times")
        end
      end
    end

    context "mutiple times" do
      subject(:matches?) { instance.times(2).matches?(AJob) }

      context "correct number of times" do
        context "as the only job" do
          let(:enqueued_jobs) { [{ job: AJob, args: [] }, { job: AJob, args: [] }] }

          it { is_expected.to be(true) }
        end

        context "with other jobs" do
          let(:enqueued_jobs) do
            [{ job: AJob, args: [] }, { job: AJob, args: [] }, { job: BJob, args: [] }]
          end

          it { is_expected.to be(true) }
        end
      end

      context "wrong number of times" do
        let(:enqueued_jobs) do
          [{ job: AJob, args: [] }]
        end

        it { is_expected.to be(false) }

        specify do
          matches?
          expect(instance.failure_message).
            to eq("expected to enqueue a AJob 2 times, but enqueued once")
        end
      end
    end
  end
end
