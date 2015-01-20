require 'global_id'

module RSpec
  module ActiveJob
    module Matchers
      class GlobalID
        def initialize(expected)
          unless valid_expected?(expected)
            raise "expected argument must implement to_global_id"
          end

          @expected = expected
        end

        def ===(other)
          other.is_a?(Hash) &&
            other.keys == ['_aj_globalid'] &&
            global_id_matches?(other['_aj_globalid'])
        end

        def description
          "serialized global ID of #{@expected}" unless @expected.is_a?(Class)
          "serialized global ID of #{@expected.name}"
        end

        private

        def valid_expected?(expected)
          return expected.instance_method(:to_global_id) if expected.is_a?(Class)
          expected.respond_to?(:to_global_id)
        end

        def global_id_matches?(other)
          parsed = ::GlobalID.parse(other)
          return false unless parsed
          return correct_class?(parsed) if @expected.is_a?(Class)
          other == @expected.to_global_id.to_s
        end

        def correct_class?(other)
          other.app == ::GlobalID.app &&
            other.model_class == @expected
        end
      end
    end
  end
end
