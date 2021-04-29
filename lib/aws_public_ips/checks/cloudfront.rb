# frozen_string_literal: true

require 'aws-sdk-cloudfront'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Cloudfront
      def self.run(options)
        ::AwsPublicIps::Utils.probe(::Aws::CloudFront::Client, options[:regions] & ['us-east-1'],
                                    options[:progress]) do |client|
          # Cloudfront distributions are always public, they don't have a concept of VPC
          # No "coming up" problem here like with RDS/Redshift

          client.list_distributions.flat_map do |response|
            response.distribution_list.items.flat_map do |distribution|
              {
                id: distribution.id,
                hostname: distribution.domain_name,
                ip_addresses: ::AwsPublicIps::Utils.resolve_hostname(distribution.domain_name)
              }
            end
          end
        end
      end
    end
  end
end
