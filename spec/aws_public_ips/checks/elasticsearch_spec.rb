# frozen_string_literal: true

describe ::AwsPublicIps::Checks::Elasticsearch do
  it 'should return elasticsearch ips' do
    stub_request(:get, 'https://es.us-east-1.amazonaws.com/2015-01-01/domain')
      .to_return(body: ::IO.read('spec/fixtures/elasticsearch-list.json'))
    stub_request(:get, 'https://es.us-east-1.amazonaws.com/2015-01-01/es/domain/classic')
      .to_return(body: ::IO.read('spec/fixtures/elasticsearch-describe-classic.json'))
    stub_request(:get, 'https://es.us-east-1.amazonaws.com/2015-01-01/es/domain/vpc')
      .to_return(body: ::IO.read('spec/fixtures/elasticsearch-describe-vpc.json'))

    stub_dns(
      'search-classic-fd5cbkkjuuiudho2lrwmsjp6rm.us-east-1.es.amazonaws.com' => %w[54.0.0.1]
    )

    expect(subject.run).to eq([
      {
        id: '154967844790/classic',
        hostname: 'search-classic-fd5cbkkjuuiudho2lrwmsjp6rm.us-east-1.es.amazonaws.com',
        ip_addresses: %w[54.0.0.1]
      }
    ])
  end
end
