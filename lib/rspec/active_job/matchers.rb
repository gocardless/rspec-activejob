module RSpec
  module ActiveJob
    module Matchers
      class EnqueueA
        def initialize(job_class = nil)
          @job_class = job_class
        end

        def matches?(block)
          @before_jobs = enqueued_jobs.dup
          block.call
          enqueued_something? && enqueued_correct_class? && with_correct_args?
        end

        def with(*args)
          raise "Must specify the job class when specifying arguments" unless job_class

          @expected_args = args
          self
        end

        def failure_message
          unless enqueued_something?
            return "expected to enqueue a #{job_class || 'job'}, enqueued nothing"
          end

          unless enqueued_correct_class?
            return "expected to enqueue a #{job_class}, enqueued a #{enqueued_jobs.last[:job]}"
          end

          "expected to enqueue a #{job_class} with #{expected_args}, but enqueued with " \
          "#{new_jobs_with_correct_class.first[:args]}"
        end

        def supports_block_expectations?
          true
        end

        private

        attr_reader :before_count, :after_count, :job_class, :expected_args

        def enqueued_something?
          new_jobs.any?
        end

        def enqueued_correct_class?
          return true unless job_class
          new_jobs_with_correct_class.any?
        end

        def with_correct_args?
          return true unless expected_args
          new_jobs_with_correct_class_and_args.any?
        end

        def new_jobs
          enqueued_jobs - @before_jobs
        end

        def new_jobs_with_correct_class
          new_jobs.select { |job| job[:job] == job_class }
        end

        def new_jobs_with_correct_class_and_args
          new_jobs_with_correct_class.select { |job| job[:args] == expected_args }
        end

        def enqueued_jobs
          ::ActiveJob::Base.queue_adapter.enqueued_jobs
        end
      end
    end
  end
end
