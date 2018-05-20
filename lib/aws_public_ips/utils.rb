# frozen_string_literal: true

require 'resolv'

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
  end
end
