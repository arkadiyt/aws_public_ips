# frozen_string_literal: true

require 'resolv'
require 'aws-partitions'

module AwsPublicIps
  module Utils
    def self.resolve_hostnames(hostnames)
      hostnames.flat_map(&method(:resolve_hostname))
    end

    def self.resolve_hostname(hostname)
      # Default Resolv.getaddresses doesn't seem to return IPv6 results
      resources = ::Resolv::DNS.open do |dns|
        dns.getresources(hostname, ::Resolv::DNS::Resource::IN::A) +
          dns.getresources(hostname, ::Resolv::DNS::Resource::IN::AAAA)
      end

      resources.map do |resource|
        resource.address.to_s.downcase
      end
    end

    def self.has_service?(client)
      region_partition = ::Aws::Partitions.partitions.find do |partition|
        partition.regions.map(&:name).include?(client.config.region)
      end
      service_name = client.class.to_s.split('::')[-2]

      aws_service = region_partition.services.find { |service| service.name == service_name }
      !aws_service.regionalized? || aws_service.regions.include?(client.config.region)
    end
  end
end
