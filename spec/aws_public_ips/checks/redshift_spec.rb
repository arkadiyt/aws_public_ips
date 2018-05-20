# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Redshift do
  it 'should return redshift ips for classic public clusters' do
    stub_request(:post, 'https://redshift.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/redshift-classic-public.xml'))

    expect(subject.run).to eq([
      {
        id: 'classic',
        hostname: 'classic.csorkyt5dk7h.us-east-1.redshift.amazonaws.com',
        ip_addresses: %w[54.167.97.240 54.91.252.196 54.242.227.110]
      }
    ])
  end

  it 'should return redshift ips for vpc public clusters' do
    stub_request(:post, 'https://redshift.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/redshift-vpc-public.xml'))

    stub_dns(
      'vpc-public-2.csorkyt5dk7h.us-east-1.redshift.amazonaws.com' => %w[54.156.7.130]
    )
    expect(subject.run).to eq([
      {
        id: 'vpc-public-2',
        hostname: 'vpc-public-2.csorkyt5dk7h.us-east-1.redshift.amazonaws.com',
        ip_addresses: %w[52.44.170.10 54.209.53.206 54.208.75.129 54.156.7.130]
      }
    ])
  end

  it 'should return nothing for vpc private clusters' do
    stub_request(:post, 'https://redshift.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/redshift-vpc-private.xml'))

    expect(subject.run).to eq([])
  end

  it 'should handle clusters with a nil endpoint' do
    stub_request(:post, 'https://redshift.us-east-1.amazonaws.com')
      .to_return(body: ::IO.read('spec/fixtures/redshift-empty-endpoint.xml'))
    expect { subject.run }.to raise_error(StandardError, /has a nil endpoint/)
  end
end
