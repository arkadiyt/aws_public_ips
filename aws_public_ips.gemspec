# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'aws_public_ips/version'

Gem::Specification.new do |gem|
  gem.name        = 'aws_public_ips'
  gem.platform    = Gem::Platform::RUBY
  gem.version     = AwsPublicIps::VERSION
  gem.authors     = ['Arkadiy Tetelman']
  gem.required_ruby_version = '>= 2.1.0'
  gem.summary     = 'A library/cli to fetch all public IP addresses associated with an AWS account'
  gem.description = gem.summary
  gem.homepage    = 'https://github.com/arkadiyt/aws_public_ips'
  gem.license     = 'MIT'
  gem.files       = Dir['lib/**/*.rb'] + Dir['bin/*']

  gem.add_dependency('aws-sdk-apigateway', '~> 1.10.0')
  gem.add_dependency('aws-sdk-cloudfront', '~> 1.2.0')
  gem.add_dependency('aws-sdk-ec2', '~> 1.33.0')
  gem.add_dependency('aws-sdk-elasticloadbalancing', '~> 1.2.0')
  gem.add_dependency('aws-sdk-elasticloadbalancingv2', '~> 1.8.0')
  gem.add_dependency('aws-sdk-elasticsearchservice', '~> 1.5.0')
  gem.add_dependency('aws-sdk-lightsail', '~> 1.4.0')
  gem.add_dependency('aws-sdk-rds', '~> 1.18.0')
  gem.add_dependency('aws-sdk-redshift', '~> 1.2.0')

  gem.add_development_dependency('bundler-audit', '~> 0.6.0')
  gem.add_development_dependency('coveralls', '~> 0.8.12')
  gem.add_development_dependency('rspec', '~> 3.7.0')
  gem.add_development_dependency('rubocop', '~> 0.55.0')
  gem.add_development_dependency('webmock', '~> 3.4.1')
end
