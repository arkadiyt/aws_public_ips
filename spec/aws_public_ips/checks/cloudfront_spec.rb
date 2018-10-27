# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Cloudfront do
  it 'should return cloudfront ips' do
    stub_request(:get, 'https://cloudfront.amazonaws.com/2018-06-18/distribution')
      .to_return(body: ::IO.read('spec/fixtures/cloudfront.xml'))

    stub_dns(
      'd22ycgwdruc4lt.cloudfront.net' => %w[54.0.0.1 54.0.0.2],
      'd1k00qwg2uxphp.cloudfront.net' => %w[54.0.0.3]
    )
    expect(subject.run).to eq([
      {
        id: 'E1DABYDY46RHFK',
        hostname: 'd22ycgwdruc4lt.cloudfront.net',
        ip_addresses: %w[54.0.0.1 54.0.0.2]
      },
      {
        id: 'E3SFCHHIPK43DR',
        hostname: 'd1k00qwg2uxphp.cloudfront.net',
        ip_addresses: %w[54.0.0.3]
      }
    ])
  end
end
