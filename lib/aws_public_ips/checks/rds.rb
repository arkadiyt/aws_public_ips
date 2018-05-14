# frozen_string_literal: true

require 'aws-sdk-rds'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Rds
      def self.run
        client = Aws::RDS::Client.new

        # TODO(arkadiy) not sure if this is true anymore after redshift, do more testing
        # RDS instances can be:
        # - launched into classic
        # - launched into VPC
        # - launched into a VPC but marked as `publicly_accessible`, in which case the VPC must have an Internet
        # Gateway attached, and the DNS endpoint will resolve to a public ip address
        client.describe_db_instances.flat_map do |response|
          response.db_instances.flat_map do |instance|
            next [] unless instance.publicly_accessible
            {
              id: instance.dbi_resource_id,
              hostname: instance.endpoint.address,
              ip_addresses: Utils.resolve_hostname(instance.endpoint.address)
            }
          end
        end
      end
    end
  end
end
