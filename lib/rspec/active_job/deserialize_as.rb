require 'active_job/arguments'
require 'active_support/core_ext/hash/indifferent_access'

module RSpec
  module ActiveJob
    module Matchers
      class DeserializeAs
        def initialize(expected)
          @expected = expected
        end

        def ===(other)
          deserialize(other).class == @expected.class &&
            deserialize(other) == @expected
        end

        def description
          "an object deserializing to #{@expected}"
        end

        private

        def deserialize(argument)
          ::ActiveJob::Arguments.deserialize([argument]).first
        end
      end
    end
  end
end
