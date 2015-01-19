module RSpec
  module ActiveJob
    module Matchers
      class GlobalID
        def initialize(expected)
          unless expected.respond_to?(:to_global_id)
            raise "expected argument must implement to_global_id"
          end

          @expected = expected.to_global_id.to_s
        end

        def ===(other)
          other.is_a?(Hash) &&
            other.keys == ['_aj_globalid'] &&
            other['_aj_globalid'] == @expected
        end
      end
    end
  end
end

