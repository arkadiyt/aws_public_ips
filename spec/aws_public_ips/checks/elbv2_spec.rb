# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Elbv2 do
  it 'should return elbv2 ips' do
    stub_request(:post, 'https://elasticloadbalancing.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/elbv2.xml'))

    stub_dns(
      'nlb-vpc-d243d0acc9151631.elb.us-east-1.amazonaws.com' => %w[54.0.0.1],
      'alb-vpc-228877692.us-east-1.elb.amazonaws.com' => %w[54.0.0.2 2600:1f18:63e0:b401:b952:5715:d981:2776]
    )

    expect(subject.run).to eq([
      {
        id: 'Z26RNL4JYFTOTI',
        hostname: 'nlb-vpc-d243d0acc9151631.elb.us-east-1.amazonaws.com',
        ip_addresses: %w[54.0.0.1]
      },
      {
        id: 'Z35SXDOTRQ7X7K',
        hostname: 'alb-vpc-228877692.us-east-1.elb.amazonaws.com',
        ip_addresses: %w[54.0.0.2 2600:1f18:63e0:b401:b952:5715:d981:2776]
      }
    ])
  end
end
