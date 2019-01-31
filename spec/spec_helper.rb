# frozen_string_literal: true

require 'coveralls'
::Coveralls.wear! do |config|
  # Output html report for development & default json report for Travis/Coveralls
  config.formatter = SimpleCov::Formatter::HTMLFormatter unless ::ENV['TRAVIS']
  config.add_filter 'spec'
end
::ENV['COVERALLS_NOISY'] = '1'
require 'webmock/rspec'
require 'aws_public_ips'

# So the AWS gem doesn't try to hit the metadata endpoint
::ENV['AWS_REGION'] = 'us-east-1'
::ENV['AWS_ACCESS_KEY_ID'] = 'AAAAAAAAAAAAAAAAAAAA'
::ENV['AWS_SECRET_ACCESS_KEY'] = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'

def stub_dns(mapping)
  mapping.each do |hostname, ips|
    expect(::AwsPublicIps::Utils).to receive(:resolve_hostname).with(hostname).and_return(ips)
  end
end

def stub_describe_regions
  stub_request(:post, 'https://ec2.us-east-1.amazonaws.com/')
    .with(body: /Action=DescribeRegions/)
    .to_return(status: 200, body: ::IO.read('spec/fixtures/describe-regions.xml'))
end

def run_check(subject)
  subject.run(regions: [::ENV['AWS_REGION']], progress: false)
end
