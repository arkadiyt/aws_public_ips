# frozen_string_literal: true

describe ::AwsPublicIps::Utils do
  it 'should resolve a single hostname' do
    hostname = 'www.example.com'

    expect(::Resolv::DNS).to receive(:open) do |&block|
      dns = double('dns')
      expect(dns).to receive(:getresources).with(hostname, ::Resolv::DNS::Resource::IN::A)
        .and_return([double(address: '54.0.0.1')])
      expect(dns).to receive(:getresources).with(hostname, ::Resolv::DNS::Resource::IN::AAAA)
        .and_return([double(address: '2606:2800:220:1:248:1893:25c8:1946')])
      block.call(dns)
    end

    expect(::AwsPublicIps::Utils.resolve_hostname(hostname)).to eq(%w[54.0.0.1 2606:2800:220:1:248:1893:25c8:1946])
  end

  it 'should resolve multiple hostnames' do
    mapping = {
      'example.com' => %w[54.0.0.1],
      'www.example.com' => %w[54.0.0.2]
    }

    mapping.each do |hostname, ips|
      expect(::AwsPublicIps::Utils).to receive(:resolve_hostname).with(hostname).and_return(ips)
    end

    expect(::AwsPublicIps::Utils.resolve_hostnames(mapping.keys)).to eq(mapping.values.flatten)
  end
end
