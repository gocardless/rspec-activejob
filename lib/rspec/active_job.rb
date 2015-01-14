require 'rspec/active_job/matchers'
module RSpec
  module ActiveJob
    def enqueue_a(job_class)
      Matchers::EnqueueA.new(job_class)
    end
  end
end
