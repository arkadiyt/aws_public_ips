# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Ec2
      def self.run(all)
        client = ::Aws::EC2::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        results = []

        if all
          results += client.describe_nat_gateways.flat_map do |response|
            response.nat_gateways.flat_map do |gateway|
              ip_addresses = gateway.nat_gateway_addresses.map { |addresses| addresses.public_ip }

              # Don't return an entry if all ips were private
              next [] if ip_addresses.empty?

              {
                id: gateway.nat_gateway_id,
                hostname: nil,
                ip_addresses: ip_addresses.uniq
              }
            end
          end
        end

        # Iterate over all EC2 instances. This will include those from EC2, ECS, EKS, Fargate, Batch,
        # Beanstalk, and NAT Instances
        results += client.describe_instances.flat_map do |response|
          response.reservations.flat_map do |reservation|
            reservation.instances.flat_map do |instance|
              # EC2-Classic instances have a `public_ip_address` and no `network_interfaces`
              # EC2-VPC instances both set, so we uniq the ip addresses
              ip_addresses = [instance.public_ip_address].compact + instance.network_interfaces.flat_map do |interface|
                public_ip = []

                interface.private_ip_addresses.flat_map do |private_ip|
                  if private_ip.association && private_ip.association.public_ip
                    public_ip << private_ip.association.public_ip
                  end
                end
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

        results
      end
    end
  end
end
