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
end
