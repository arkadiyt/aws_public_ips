# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Rds do
  it 'should return rds ips' do
    stub_request(:post, 'https://rds.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/rds.xml'))

    stub_dns(
      'public-vpc.cyvjlokb0o75.us-east-1.rds.amazonaws.com' => %w[35.171.145.174],
      'public-vpc-us-east-1f.cyvjlokb0o75.us-east-1.rds.amazonaws.com' => %w[52.70.34.110]
    )

    expect(subject.run).to eq([
      {
        id: 'db-2PJZVWW2J4CRFH5FNEOE2TL7EA',
        hostname: 'public-vpc.cyvjlokb0o75.us-east-1.rds.amazonaws.com',
        ip_addresses: %w[35.171.145.174]
      },
      {
        id: 'db-56FZRB5ILTQNES6QSM5C5RVP34',
        hostname: 'public-vpc-us-east-1f.cyvjlokb0o75.us-east-1.rds.amazonaws.com',
        ip_addresses: %w[52.70.34.110]
      }
    ])
  end
end
