# frozen_string_literal: true

require 'aws-sdk-elasticloadbalancingv2'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Elbv2
      def self.run
        client = ::Aws::ElasticLoadBalancingV2::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # EC2-Classic load balancers are only returned by the 'elasticloadbalancing' API, and
        # EC2-VPC ALBs/NLBs are only returned by the 'elasticloadbalancingv2' API

        # NLBs only support IPv4
        # ALBs support IPv4 or dualstack. Unlike Classic ELBs which have a separate IPv6 DNS name,
        # dualstack ALBs only have a single DNS name
        client.describe_load_balancers.flat_map do |response|
          response.load_balancers.flat_map do |load_balancer|
            next [] unless load_balancer.scheme == 'internet-facing'

            {
              id: load_balancer.canonical_hosted_zone_id,
              hostname: load_balancer.dns_name,
              ip_addresses: ::AwsPublicIps::Utils.resolve_hostname(load_balancer.dns_name)
            }
          end
        end
      end
    end
  end
end
