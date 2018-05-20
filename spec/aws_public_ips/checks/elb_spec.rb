# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Elb do
  it 'should return elb ips' do
    stub_request(:post, 'https://elasticloadbalancing.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/elb.xml'))

    stub_dns(
      'classic-272004174.us-east-1.elb.amazonaws.com' => %w[54.0.0.1],
      'ipv6.classic-272004174.us-east-1.elb.amazonaws.com' => %w[2600:1f18:63e0:b401:b952:5715:d981:2776]
    )

    expect(subject.run).to eq([
      {
        id: 'Z35SXDOTRQ7X7K',
        hostname: 'classic-272004174.us-east-1.elb.amazonaws.com',
        ip_addresses: %w[54.0.0.1 2600:1f18:63e0:b401:b952:5715:d981:2776]
      }
    ])
  end
end
