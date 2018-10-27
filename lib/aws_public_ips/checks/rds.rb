# frozen_string_literal: true

require 'aws-sdk-rds'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Rds
      def self.run
        client = ::Aws::RDS::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # RDS instances can be launched into VPCs or into Classic mode.
        # In classic mode they are always public.
        # In VPC mode they can be marked as `publicly_accessible` or not - if they are then its VPC must have
        # an Internet Gateway attached, and the DNS endpoint will resolve to a public ip address.
        client.describe_db_instances.flat_map do |response|
          response.db_instances.flat_map do |instance|
            next [] unless instance.publicly_accessible

            if instance.endpoint.nil?
              raise StandardError, "RDS DB '#{instance.dbi_resource_id}' has a nil endpoint. This likely" \
                ' means the DB is being brought up right now.'
            end

            {
              id: instance.dbi_resource_id,
              hostname: instance.endpoint.address,
              ip_addresses: ::AwsPublicIps::Utils.resolve_hostname(instance.endpoint.address)
            }
          end
        end
      end
    end
  end
end
