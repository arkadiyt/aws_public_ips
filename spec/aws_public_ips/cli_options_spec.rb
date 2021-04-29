# frozen_string_literal: true

describe ::AwsPublicIps::CLIOptions do
  it 'should parse the options' do
    stub_describe_regions
    options = subject.parse(%w[--format json --services ec2,elb,redshift --verbose])
    expect(options).to eq(format: 'json', progress: false, regions: ['us-east-1'],
                          services: %w[ec2 elb redshift], tags: nil, verbose: true)
  end

  it 'should raise on an invalid formatter' do
    stub_describe_regions
    expect { subject.parse(%w[--format blah]) }.to raise_error(::ArgumentError, /Invalid format/)
  end

  it 'should raise on an invalid service' do
    stub_describe_regions
    expect { subject.parse(%w[--service blah]) }.to raise_error(::ArgumentError, /Invalid service/)
  end

  it 'should select the right directory' do
    stub_describe_regions
    ::Dir.chdir('/') do
      options = subject.parse(%w[--service ec2 --format prettyjson])
      expect(options).to include(services: %w[ec2], format: 'prettyjson')
    end
  end

  it 'should raise on an invalid region' do
    stub_describe_regions
    expect { subject.parse(%w[--region blah]) }.to raise_error(::ArgumentError, /Invalid region/)
  end

  it 'should allow all regions to be specified' do
    stub_describe_regions
    options = subject.parse(%w[--region all])
    expect(options).to(satisfy { |o| o[:regions].length == 16 })
  end

  it 'should allow tags to be included' do
    stub_describe_regions
    options = subject.parse(%w[--include_tags name,service,name])
    expect(options[:tags]).to contain_exactly('name', 'service')
  end

  it 'should allow progress to be enabled' do
    stub_describe_regions
    options = subject.parse(%w[--progress])
    expect(options[:progress]).to be_truthy
  end

  it 'should be able to print usage' do
    expect(subject.usage).to include('Usage: aws_public_ips')
  end
end
