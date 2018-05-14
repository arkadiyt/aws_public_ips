# frozen_string_literal: true

describe AwsPublicIps::Checks::Redshift do
  it 'should return redshift ips' do
    stub_request(:post, 'https://redshift.us-east-1.amazonaws.com')
      .to_return(body: IO.read('spec/fixtures/redshift.xml'))

    # TODO(arkadiy) want to launch VPC cluster but can't - try again later
    expect(subject.run).to eq([
      {
        id: 'classic',
        hostname: 'classic.csorkyt5dk7h.us-east-1.redshift.amazonaws.com',
        ip_addresses: %w[54.167.97.240 54.91.252.196 54.242.227.110]
      }
    ])
  end
end
