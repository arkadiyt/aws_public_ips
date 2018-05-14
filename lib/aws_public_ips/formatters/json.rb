# frozen_string_literal: true

require 'json'

module AwsPublicIps
  module Formatters
    class Json
      def initialize(results)
        @results = results
      end

      def format
        @results.to_json
      end
    end
  end
end
