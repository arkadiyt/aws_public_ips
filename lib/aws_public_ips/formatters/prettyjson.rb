# frozen_string_literal: true

require 'json'

module AwsPublicIps
  module Formatters
    class Prettyjson
      def initialize(results, options)
        @results = results
        @options = options
      end

      def format
        ::JSON.pretty_generate(@results)
      end
    end
  end
end
