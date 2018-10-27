# frozen_string_literal: true

require 'aws-sdk-redshift'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Redshift
      def self.run
        client = ::Aws::Redshift::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # Redshift clusters can be launched into VPCs or into Classic mode.
        # In classic mode they are always public.
        # In VPC mode they can be marked as `publicly_accessible` or not - if they are then its VPC must have
        # an Internet Gateway attached, and the DNS endpoint will resolve to a public ip address.
        client.describe_clusters.flat_map do |response|
          response.clusters.flat_map do |cluster|
            next [] unless cluster.publicly_accessible

            if cluster.endpoint.nil?
              raise StandardError, "Redshift cluster '#{cluster.cluster_identifier}' has a nil endpoint. This likely" \
                ' means the cluster is being brought up right now.'
            end

            {
              id: cluster.cluster_identifier,
              hostname: cluster.endpoint.address,
              ip_addresses: cluster.cluster_nodes.map(&:public_ip_address) +
                ::AwsPublicIps::Utils.resolve_hostname(cluster.endpoint.address)
            }
          end
        end
      end
    end
  end
end
