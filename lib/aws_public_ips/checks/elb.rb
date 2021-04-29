# frozen_string_literal: true

require 'aws-sdk-elasticloadbalancing'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Elb
      def self.run(options)
        # EC2-Classic load balancers are only returned by the 'elasticloadbalancing' API, and
        # EC2-VPC ALBs/NLBs are only returned by the 'elasticloadbalancingv2' API
        ::AwsPublicIps::Utils.probe(::Aws::ElasticLoadBalancing::Client,
                                    options[:regions], options[:progress]) do |client|
          client.describe_load_balancers.flat_map do |response|
            response.load_balancer_descriptions.flat_map do |load_balancer|
              next [] unless load_balancer.scheme == 'internet-facing'

              # EC2-Classic load balancers get IPv6 DNS records created but they are not returned by the API
              hostnames = [load_balancer.dns_name, "ipv6.#{load_balancer.dns_name}"]
              {
                region: client.config.region,
                id: load_balancer.canonical_hosted_zone_name_id,
                hostname: load_balancer.dns_name,
                ip_addresses: ::AwsPublicIps::Utils.resolve_hostnames(hostnames)
              }
            end
          end
        end
      end
    end
  end
end
