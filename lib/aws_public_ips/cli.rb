# frozen_string_literal: true

require 'aws_public_ips/cli_options'

module AwsPublicIps
  class CLI
    def check_service(options, service)
      require "aws_public_ips/checks/#{service}.rb"
      ::AwsPublicIps::Checks.const_get(service.capitalize).run(options)
    end

    def output(formatter, options, results)
      require "aws_public_ips/formatters/#{formatter}.rb"
      formatter_klass = ::AwsPublicIps::Formatters.const_get(formatter.capitalize)
      output = formatter_klass.new(results, options).format
      ::STDOUT.puts output unless output.empty?
    end

    def run(args)
      cli_options = ::AwsPublicIps::CLIOptions.new
      parse_and_run(cli_options, args)
    end

    def parse_and_run(cli_options, args)
      options = cli_options.parse(args)
      return unless options

      results = options[:services].map do |service|
        [service.to_sym, check_service(options, service)]
      end.to_h

      output(options[:format], options, results)
    rescue OptionParser::InvalidOption, ArgumentError => ex
      ::STDOUT.puts ex
      ::STDOUT.puts cli_options.usage
      ::Process.exit(1)
    rescue ::StandardError, ::Interrupt => ex
      ::STDERR.puts ex.inspect
      ::STDERR.puts ex.backtrace if options && options[:verbose]
      ::Process.exit(1)
    end
  end
end
