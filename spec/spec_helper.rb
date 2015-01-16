require 'rspec/active_job'
require 'pry'

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.disable_monkey_patching!
end

module ActiveJob
  class Base
    def self.queue_adapter
      Struct.new(:enqueued_jobs).new(enqueued_jobs: [])
    end
  end
end
