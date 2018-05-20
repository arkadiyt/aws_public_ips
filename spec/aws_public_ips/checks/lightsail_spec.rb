# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Lightsail do
  it 'should return lightsail ips' do
    stub_request(:post, 'https://lightsail.us-east-1.amazonaws.com')
      .to_return({body: ::IO.read('spec/fixtures/lightsail-instance.json')},
                 body: ::IO.read('spec/fixtures/lightsail-load-balancer.json'))

    stub_dns(
      'ce551c6f952085b4126e4b523a100eda-232829524.us-east-1.elb.amazonaws.com' => %w[54.88.163.90 52.205.146.152]
    )

    expect(subject.run).to eq([
      {
        id: 'Amazon_Linux-512MB-Virginia-1',
        hostname: nil,
        ip_addresses: %w[18.206.153.10]
      },
      {
        id: 'LoadBalancer-Virginia-1',
        hostname: 'ce551c6f952085b4126e4b523a100eda-232829524.us-east-1.elb.amazonaws.com',
        ip_addresses: %w[54.88.163.90 52.205.146.152]
      }
    ])
  end
end
