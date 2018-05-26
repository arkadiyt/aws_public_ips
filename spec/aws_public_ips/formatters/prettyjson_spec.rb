# frozen_string_literal: true

describe ::AwsPublicIps::Formatters::Prettyjson do
  it 'should output the right format' do
    results = {
      ec2: [{
        id: 'i-0f22d0af796b3cf3a',
        hostname: 'ec2-54-234-208-236.compute-1.amazonaws.com',
        ip_addresses: %w[54.234.208.236]
      }]
    }

    expect(::AwsPublicIps::Formatters::Prettyjson.new(results, {}).format).to include('54.234.208.236')
  end
end
