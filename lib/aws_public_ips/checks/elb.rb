# frozen_string_literal: true

require 'aws-sdk-elasticloadbalancing'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Elb
      def self.run
        client = Aws::ElasticLoadBalancing::Client.new

        # EC2-Classic load balancers are only returned by the 'elasticloadbalancing' API, and
        # EC2-VPC ALBs/NLBs are only returned by the 'elasticloadbalancingv2' API
        client.describe_load_balancers.flat_map do |response|
          response.load_balancer_descriptions.flat_map do |load_balancer|
            next [] unless load_balancer.scheme == 'internet-facing'
            {
              id: load_balancer.canonical_hosted_zone_name_id,
              hostname: load_balancer.dns_name,
              # EC2-Classic load balancers get IPv6 DNS records created but they are not returned by the API
              ip_addresses: Utils.resolve_hostnames([load_balancer.dns_name, "ipv6.#{load_balancer.dns_name}"])
            }
          end
        end
      end
    end
  end
end
