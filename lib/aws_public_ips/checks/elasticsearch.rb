# frozen_string_literal: true

require 'aws-sdk-elasticsearchservice'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Elasticsearch
      def self.run
        client = ::Aws::ElasticsearchService::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # ElasticSearch instances can be launched into classic into VPCs. Classic instances are public and have a
        # `domain_status.endpoint` hostname, and VPC instances have a `domain_status.endpoints['vpc']` hostname.
        # However VPC ElasticSearch instances create their own Network Interface and AWS will not allow you
        # to associate an Elastic IP to it. As a result VPC ElasticSearch instances are always private, even with an
        # internet gateway.

        client.list_domain_names.flat_map do |response|
          response.domain_names.flat_map do |domain_name|
            client.describe_elasticsearch_domain(domain_name: domain_name.domain_name).map do |domain|
              hostname = domain.domain_status.endpoint
              next unless hostname

              {
                id: domain.domain_status.domain_id,
                hostname: hostname,
                ip_addresses: ::AwsPublicIps::Utils.resolve_hostname(hostname)
              }
            end.compact
          end
        end
      end
    end
  end
end
