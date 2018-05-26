# frozen_string_literal: true

describe ::AwsPublicIps::Formatters::Text do
  let(:entry) do
    {
      id: 'i-0f22d0af796b3cf3a',
      hostname: 'ec2-54-234-208-236.compute-1.amazonaws.com',
      ip_addresses: %w[54.234.208.236]
    }
  end

  let(:results) do
    {
      ec2: [entry]
    }
  end

  it 'should output the right format' do
    expect(::AwsPublicIps::Formatters::Text.new(results, {}).format).to eq(entry[:ip_addresses].join("\n"))
  end

  it 'should output id and hostname if using verbose mode' do
    output = ::AwsPublicIps::Formatters::Text.new(results, verbose: true).format
    expect(output).to include(entry[:id])
    expect(output).to include(entry[:hostname])
    expect(output).to include(entry[:ip_addresses].join("\n"))
  end
end
