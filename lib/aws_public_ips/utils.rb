# frozen_string_literal: true

require 'resolv'
require 'aws-partitions'
require 'tty-spinner'

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
      service_name = service_name(client.class)

      aws_service = region_partition.services.find { |service| service.name == service_name }
      !aws_service.regionalized? || aws_service.regions.include?(client.config.region)
    end

    def self.add_tags(result, source, tags)
      return unless tags && source.tags

      tags.each do |tag|
        tag_item = source.tags.find { |t| t.key.downcase == tag }
        if tag_item
          tag_key = tag_item.key.downcase
          result[tag_key.to_sym] = tag_item.value
        end
      end
    end

    def self.probe(client_class, regions, progress, &block)
      return [] unless regions && !regions.empty?

      if progress
        service_name = service_name(client_class)
        spinners = create_spinner(TTY::Spinner::Multi, service_name)
        begin
          child_spinners = regions.map { |r| [r, spinners.register("[:spinner] #{r}")] }.to_h
          result = regions.flat_map do |region|
            probe_region_with_progress(child_spinners[region], client_class, region, &block)
          end
          spinners.success
          result
        rescue StandardError
          spinners.error
          []
        end
      else
        regions.flat_map do |region|
          probe_region(client_class, region, &block)
        end
      end
    end

    def self.service_name(client_class)
      client_class.to_s.split('::')[-2]
    end

    def self.create_spinner(spinner_class, service_name)
      spinner_class.new("[:spinner] Probing #{service_name}...",
                        format: :dots,
                        success_mark: '+',
                        errror_mark: 'x')
    end

    def self.probe_region_with_progress(spinner, client_class, region, &block)
      spinner.run do |s|
        begin
          result = probe_region(client_class, region, &block)
          s.success
          result
        rescue StandardError
          s.error
          []
        end
      end.value
    end

    def self.probe_region(client_class, region, &block)
      client = region ? client_class.new(region: region) : client_class.new
      return [] unless ::AwsPublicIps::Utils.has_service?(client)

      block.call(client)
    end
  end
end
