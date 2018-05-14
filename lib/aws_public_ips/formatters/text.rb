# frozen_string_literal: true

module AwsPublicIps
  module Formatters
    class Text
      def initialize(results)
        @results = results
      end

      def format
        @results.values.flatten.flat_map do |hash|
          hash[:ip_addresses]
        end.uniq.join("\n")
      end
    end
  end
end
