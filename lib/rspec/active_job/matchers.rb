module RSpec
  module ActiveJob
    module Matchers
      class EnqueueA
        def initialize(job_class = nil)
          @job_class = job_class
        end

        def matches?(block)
          @before_count = enqueued_jobs.count
          block.call
          @after_count = enqueued_jobs.count
          enqueued_something? && enqueued_correct_class? && with_correct_args?
        end

        def with(*args)
          @expected_args = args
          self
        end

        def failure_message
          unless enqueued_something?
            return "expected to enqueue a #{job_class}, enqueued nothing"
          end

          unless enqueued_correct_class?
            return "expected to enqueue a #{job_class}, enqueued a #{enqueued_jobs.last[:job]}"
          end

          "expected to enqueue a #{job_class} with #{expected_args}, but enqueued with " \
          "#{actual_args}"
        end

        def supports_block_expectations?
          true
        end

        private

        attr_reader :before_count, :after_count, :job_class, :expected_args

        def enqueued_something?
          enqueued_jobs.count - before_count == 1
        end

        def enqueued_correct_class?
          return true unless job_class
          enqueued_jobs.last[:job] == job_class
        end

        def with_correct_args?
          return true unless expected_args
          actual_args == expected_args
        end

        def actual_args
          enqueued_jobs.last[:args]
        end

        def enqueued_jobs
          ::ActiveJob::Base.queue_adapter.enqueued_jobs
        end
      end
    end
  end
end
