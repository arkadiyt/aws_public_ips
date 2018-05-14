# frozen_string_literal: true

require 'json'

module AwsPublicIps
  module Formatters
    class Prettyjson
      def initialize(results)
        @results = results
      end

      def format
        JSON.pretty_generate(@results)
      end
    end
  end
end
