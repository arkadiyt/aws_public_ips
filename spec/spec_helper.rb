# frozen_string_literal: true

require 'coveralls'
::Coveralls.wear! do |config|
  # Output html report for development & default json report for Travis/Coveralls
  config.formatter = SimpleCov::Formatter::HTMLFormatter unless ::ENV['TRAVIS']
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
