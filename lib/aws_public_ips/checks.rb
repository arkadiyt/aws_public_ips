# frozen_string_literal: true

module AwsPublicIps
  module Checks
  end
end

require 'aws_public_ips/checks/apigateway'
require 'aws_public_ips/checks/cloudfront'
require 'aws_public_ips/checks/ec2'
require 'aws_public_ips/checks/elasticsearch'
require 'aws_public_ips/checks/elb'
require 'aws_public_ips/checks/elbv2'
require 'aws_public_ips/checks/lightsail'
require 'aws_public_ips/checks/rds'
require 'aws_public_ips/checks/redshift'
