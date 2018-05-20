# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Rds do
  it 'should return rds ips for vpc public instances' do
    stub_request(:post, 'https://rds.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/rds-vpc-public.xml'))

    stub_dns(
      'rds-vpc-public.cyvjlokb0o75.us-east-1.rds.amazonaws.com' => %w[35.171.145.174],
      'rds-vpc-public-us-east-1a.cyvjlokb0o75.us-east-1.rds.amazonaws.com' => %w[52.70.34.110]
    )

    expect(subject.run).to eq([
      {
        id: 'db-BAKGGXYRB3EBKBDQZTAMDSGCXY',
        hostname: 'rds-vpc-public.cyvjlokb0o75.us-east-1.rds.amazonaws.com',
        ip_addresses: %w[35.171.145.174]
      },
      {
        id: 'db-B3N4GULDAFGDKEGXBD7CXKZQV4',
        hostname: 'rds-vpc-public-us-east-1a.cyvjlokb0o75.us-east-1.rds.amazonaws.com',
        ip_addresses: %w[52.70.34.110]
      }
    ])
  end

  it 'should return nothing for vpc private db instances' do
    stub_request(:post, 'https://rds.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/rds-vpc-private.xml'))

    expect(subject.run).to eq([])
  end

  it 'should handle db instances with a nil endpoint' do
    stub_request(:post, 'https://rds.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/rds-empty-endpoint.xml'))

    expect { subject.run }.to raise_error(StandardError, /has a nil endpoint/)
  end
end
