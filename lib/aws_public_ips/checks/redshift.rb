# frozen_string_literal: true

require 'aws-sdk-redshift'

module AwsPublicIps
  module Checks
    module Redshift
      def self.run
        client = Aws::Redshift::Client.new

        # TODO(arkadiy) update copy from RDS
        # Redshift clusters can only be launched into VPCs. They can be marked as `publicly_accessible`,
        # in which case the VPC must have an Internet Gateway attached, and the DNS endpoint will
        # resolve to a public ip address
        client.describe_clusters.flat_map do |response|
          response.clusters.flat_map do |cluster|
            next [] unless cluster.publicly_accessible
            {
              id: cluster.cluster_identifier,
              hostname: cluster.endpoint.address,
              ip_addresses: cluster.cluster_nodes.map(&:public_ip_address)
            }
          end
        end
      end
    end
  end
end
