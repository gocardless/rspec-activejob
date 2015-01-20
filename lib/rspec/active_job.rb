require 'rspec/active_job/enqueue_a'
require 'rspec/active_job/global_id'

module RSpec
  module ActiveJob
    def enqueue_a(job_class)
      Matchers::EnqueueA.new(job_class)
    end

    def global_id(expected)
      Matchers::GlobalID.new(expected)
    end
  end
end
