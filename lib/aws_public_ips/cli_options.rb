# frozen_string_literal: true

require 'aws-sdk-ec2'
require 'optparse'

module AwsPublicIps
  class CLIOptions
    # Supported services:
    # EC2 (and as a result: ECS, EKS, Beanstalk, Fargate, Batch, & NAT Instances)
    # ELB (Classic ELB)
    # ELBv2 (ALB/NLB)
    # RDS
    # Redshift
    # APIGateway
    # CloudFront
    # Lightsail
    # ElasticSearch

    # Services that don't need to be supported:
    # S3 - all s3 buckets resolve to the same ip addresses
    # SQS - there's a single AWS-owned domain per region (i.e. sqs.us-east-1.amazonaws.com/<account_id>/<queue_name>)
    # NAT Gateways - these do not allow ingress traffic
    # ElastiCache - all elasticache instances are private. You can make one public by using a NAT instance with an EIP:
    # https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/accessing-elasticache.html#access-from-outside-aws
    # but NAT instances are EC2 machines, so this will be caught by the EC2 check.
    # DynamoDB - no public endpoints
    # SNS - no public endpoints
    # Elastic Transcoder - no public endpoints
    # Athena - no public endpoints

    # Services that maybe have public endpoints / still need testing:
    # fargate
    # amazonmq
    # directory service (AD)
    # emr
    # Directconnect
    # Kinesis
    # SES
    # https://aws.amazon.com/products/
    # AWS Neptune (still in preview / not GA yet)
    def initialize
      @options = {
        format: 'text',
        regions: default_regions,
        services: all_services,
        tags: nil,
        verbose: false,
        progress: false
      }
      @parser = ::OptionParser.new do |p|
        p.banner = 'Usage: aws_public_ips [options]'

        p.on('-r', '--regions <r1>,<r2>,<r3>', Array, 'List of AWS services to check. Defaults to ' \
          '$AWS_DEFAULT_REGION or $AWS_REGION.  Specify `all` in include all regions.') do |regions|
          regions.map(&:downcase!).uniq!
          (regions << all_regions).flatten!.map(&:downcase!).uniq! if regions.reject! { |r| r == 'all' }
          invalid_regions = regions - all_regions
          raise ::ArgumentError, "Invalid region(s): #{invalid_regions.join(',')}" unless invalid_regions.empty?

          @options[:regions] = regions
        end

        p.on('-s', '--services <s1>,<s2>,<s3>', Array, 'List of AWS services to check. Available services: ' \
          "#{all_services.join(',')}. Defaults to all.") do |services|
          services.map(&:downcase!).uniq!
          invalid_services = services - all_services
          raise ::ArgumentError, "Invalid service(s): #{invalid_services.join(',')}" unless invalid_services.empty?

          @options[:services] = services
        end

        p.on('-t', '--include_tags <t1>,<t2>,<t3>', Array, 'List of tags to include in the results') do |tags|
          @options[:tags] = tags.map(&:downcase).uniq
        end

        p.on('-f', '--format <format>', String, 'Set output format. Available formats: ' \
          "#{all_formats.join(',')}. Defaults to text.") do |fmt|
          unless all_formats.include?(fmt)
            raise ::ArgumentError, "Invalid format '#{fmt}'. Valid formats are: #{all_formats.join(',')}"
          end

          @options[:format] = fmt
        end

        p.on('-v', '--[no-]verbose', 'Enable debug/trace output') do |verbose|
          @options[:verbose] = verbose
        end

        p.on('-p', '--[no-]progress', 'Enable progress') do |progress|
          @options[:progress] = progress
        end

        p.on_tail('--version', 'Print version') do
          require 'aws_public_ips/version'
          ::STDOUT.puts ::AwsPublicIps::VERSION
          exit 0
        end

        p.on_tail('-h', '--help', 'Show this help message') do
          ::STDOUT.puts p
          exit 0
        end
      end
    end

    def all_services
      @all_services ||= ::Dir["#{__dir__}/checks/*.rb"].map { |path| ::File.basename(path, '.rb') }.sort
    end

    def all_regions
      @all_regions ||= ::Aws::EC2::Client.new(region: 'us-east-1')
        .describe_regions.regions.flat_map(&:region_name).collect.sort
    end

    def default_regions
      return [::ENV['AWS_DEFAULT_REGION']] unless ::ENV['AWS_DEFAULT_REGION'].nil? || ::ENV['AWS_DEFAULT_REGION'].empty?

      return [::ENV['AWS_REGION']] unless ::ENV['AWS_REGION'].nil? || ::ENV['AWS_REGION'].empty?

      nil
    end

    def all_formats
      @all_formats ||= ::Dir["#{__dir__}/formatters/*.rb"].map { |path| ::File.basename(path, '.rb') }.sort
    end

    def parse(args)
      @parser.parse(args)
      raise ::ArgumentError, 'missing option: You must specify a region or set AWS_REGION.' unless @options[:regions]

      @options
    end

    def usage
      @parser.to_s
    end
  end
end
