require 'rspec/active_job/enqueue_a'
require 'rspec/active_job/global_id'
require 'rspec/active_job/deserialize_as'

module RSpec
  module ActiveJob
    def enqueue_a(job_class)
      Matchers::EnqueueA.new(job_class)
    end

    # rubocop:disable Style/PredicateName
    def have_been_enqueued
      Matchers::EnqueueA.new
    end
    # rubocop:enable Style/PredicateName

    def global_id(expected)
      Matchers::GlobalID.new(expected)
    end

    def deserialize_as(expected)
      Matchers::DeserializeAs.new(expected)
    end
  end
end
