require 'rspec/mocks/argument_list_matcher'

module RSpec
  module ActiveJob
    module Matchers
      class EnqueueA
        def initialize(job_class = nil)
          @job_class = job_class
        end

        def matches?(actual)
          raise "must use a block with enqueue_a" if !actual.is_a?(Proc) && @job_class

          if actual.is_a?(Proc)
            @before_jobs = enqueued_jobs.dup
            actual.call
            all_checks_pass?
          else
            @job_class = actual
            @before_jobs = []
            all_checks_pass?
          end
        end

        def with(*args)
          @argument_list_matcher = RSpec::Mocks::ArgumentListMatcher.new(*args)
          self
        end

        def to_run_at(time)
          @run_time = time.to_f
          self
        end

        def failure_message
          unless enqueued_something?
            return "expected to enqueue a #{job_class || 'job'}, enqueued nothing"
          end

          unless enqueued_correct_class?
            return "expected to enqueue a #{job_class}, " \
                   "enqueued a #{enqueued_jobs.last[:job]}"
          end

          unless at_correct_time?
            return "expected to run job at #{Time.at(run_time).utc}, " \
                   "but enqueued to run at #{format_enqueued_times}"
          end

          "expected to enqueue a #{job_class} with " \
          "#{argument_list_matcher.expected_args}, but enqueued with " \
          "#{new_jobs_with_correct_class.first[:args]}"
        end

        def failure_message_when_negated
          return "expected to not enqueue a job" unless job_class

          message = "expected to not enqueue a #{job_class}"
          if @argument_list_matcher
            message += " with #{argument_list_matcher.expected_args}"
          end

          message += ", but enqueued a #{enqueued_jobs.last[:job]}"

          return message unless enqueued_correct_class?

          message + " with #{new_jobs_with_correct_class.first[:args]}"
        end

        def supports_block_expectations?
          true
        end

        def description
          return "enqueue a job" unless job_class
          return "enqueue a #{job_class.name}" unless argument_list_matcher
          "enqueue a #{job_class.name} with #{argument_list_matcher.expected_args}"
        end

        private

        attr_reader :before_count, :after_count, :job_class, :argument_list_matcher,
                    :run_time

        def all_checks_pass?
          enqueued_something? &&
            enqueued_correct_class? &&
            with_correct_args? &&
            at_correct_time?
        end

        def enqueued_something?
          new_jobs.any?
        end

        def enqueued_correct_class?
          return true unless job_class
          new_jobs_with_correct_class.any?
        end

        def with_correct_args?
          return true unless argument_list_matcher
          new_jobs_with_correct_class_and_args.any?
        end

        def new_jobs
          enqueued_jobs - @before_jobs
        end

        def new_jobs_with_correct_class
          new_jobs.select { |job| job[:job] == job_class }
        end

        def new_jobs_with_correct_class_and_args
          new_jobs_with_correct_class.
            select { |job| argument_list_matcher.args_match?(*job[:args]) }
        end

        def enqueued_jobs
          ::ActiveJob::Base.queue_adapter.enqueued_jobs
        end

        def at_correct_time?
          return true unless run_time

          !new_jobs_with_correct_class.find { |job| job[:at] == run_time }.nil?
        end

        def format_enqueued_times
          new_jobs_with_correct_class.map { |job| Time.at(job[:at]).utc.to_s }.join(', ')
        end
      end
    end
  end
end
