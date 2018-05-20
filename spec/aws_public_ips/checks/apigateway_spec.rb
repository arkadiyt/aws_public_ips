# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Apigateway do
  it 'should return gateway ips' do
    stub_request(:get, 'https://apigateway.us-east-1.amazonaws.com/restapis')
      .to_return(body: ::IO.read('spec/fixtures/apigateway.json'))

    stub_dns(
      'e83d6nij2j.execute-api.us-east-1.amazonaws.com' => %w[54.0.0.1 54.0.0.2],
      'tmtmok31nc.execute-api.us-east-1.amazonaws.com' => %w[54.0.0.3]
    )

    expect(subject.run).to eq([
      {
        id: 'e83d6nij2j',
        hostname: 'e83d6nij2j.execute-api.us-east-1.amazonaws.com',
        ip_addresses: %w[54.0.0.1 54.0.0.2]
      },
      {
        id: 'tmtmok31nc',
        hostname: 'tmtmok31nc.execute-api.us-east-1.amazonaws.com',
        ip_addresses: %w[54.0.0.3]
      }
    ])
  end
end
