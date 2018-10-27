# frozen_string_literal: true

require 'aws-sdk-apigateway'
require 'aws_public_ips/utils'

module AwsPublicIps
  module Checks
    module Apigateway
      def self.run
        client = ::Aws::APIGateway::Client.new
        return [] unless ::AwsPublicIps::Utils.has_service?(client)

        # TODO(arkadiy) https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-private-integration.html

        # APIGateway doesn't return the full domain in the response, we have to build
        # it using the api id and region
        client.get_rest_apis.flat_map do |response|
          response.items.map do |api|
            hostname = "#{api.id}.execute-api.#{client.config.region}.amazonaws.com"
            {
              id: api.id,
              hostname: hostname,
              ip_addresses: ::AwsPublicIps::Utils.resolve_hostname(hostname)
            }
          end
        end
      end
    end
  end
end
