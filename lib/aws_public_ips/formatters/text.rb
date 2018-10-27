# frozen_string_literal: true

module AwsPublicIps
  module Formatters
    class Text
      def initialize(results, options)
        @results = results
        @options = options
      end

      def format
        lines = @options[:verbose] ? format_verbose : format_normal
        lines.uniq.join("\n")
      end

      def format_normal
        @results.values.flatten.flat_map do |hash|
          hash[:ip_addresses]
        end
      end

      def format_verbose
        @results.flat_map do |service, hashes|
          next [] if hashes.empty?

          ["## #{service}"] + hashes.flat_map do |hash|
            [hash[:id], hash[:hostname]].compact.map do |line|
              "# #{line}"
            end + hash[:ip_addresses]
          end
        end
      end
    end
  end
end
