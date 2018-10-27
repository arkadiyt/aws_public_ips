# frozen_string_literal: true

require 'aws-sdk-lightsail'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Lightsail
      def self.run
        client = ::Aws::Lightsail::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # Lightsail instances are always exposed directly, and can also be put behind a load balancer

        instances = client.get_instances.flat_map do |response|
          response.instances.map do |instance|
            {
              # Names are unique
              id: instance.name,
              hostname: nil,
              ip_addresses: [instance.public_ip_address]
            }
          end
        end

        load_balancers = client.get_load_balancers.flat_map do |response|
          response.load_balancers.map do |load_balancer|
            {
              # Names are unique
              id: load_balancer.name,
              hostname: load_balancer.dns_name,
              ip_addresses: ::AwsPublicIps::Utils.resolve_hostname(load_balancer.dns_name)
            }
          end
        end

        instances + load_balancers
      end
    end
  end
end
