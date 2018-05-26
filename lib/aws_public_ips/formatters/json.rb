# frozen_string_literal: true

require 'json'

module AwsPublicIps
  module Formatters
    class Json
      def initialize(results, options)
        @results = results
        @options = options
      end

      def format
        @results.to_json
      end
    end
  end
end
