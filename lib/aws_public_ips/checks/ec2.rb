# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Ec2
      def self.run
        client = ::Aws::EC2::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # Iterate over all EC2 instances. This will include those from EC2, ECS, EKS, Fargate, Batch,
        # Beanstalk, and NAT Instances
        # It will not include NAT Gateways (IPv4) or Egress Only Internet Gateways (IPv6), but they do not allow
        # ingress traffic so we skip them anyway
        client.describe_instances.flat_map do |response|
          response.reservations.flat_map do |reservation|
            reservation.instances.flat_map do |instance|
              # EC2-Classic instances have a `public_ip_address` and no `network_interfaces`
              # EC2-VPC instances both set, so we uniq the ip addresses
              ip_addresses = [instance.public_ip_address].compact + instance.network_interfaces.flat_map do |interface|
                public_ip = interface.association ? [interface.association.public_ip].compact : []
                public_ip + interface.ipv_6_addresses.map(&:ipv_6_address)
              end

              # Don't return an entry if all ips were private
              next [] if ip_addresses.empty?

              # If hostname is empty string, canonicalize to nil
              hostname = instance.public_dns_name.empty? ? nil : instance.public_dns_name
              {
                id: instance.instance_id,
                hostname: hostname,
                ip_addresses: ip_addresses.uniq
              }
            end
          end
        end
      end
    end
  end
end
