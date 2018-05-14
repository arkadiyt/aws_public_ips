# frozen_string_literal: true

describe AwsPublicIps::CLI do
  it 'should parse the options' do
    options = subject.parse(%w[--format json --services ec2,elb,redshift --verbose])
    expect(options).to eq(format: 'json', services: %w[ec2 elb redshift], verbose: true)
  end

  it 'should raise on an invalid formatter' do
    expect { subject.parse(%w[--format blah]) }.to raise_error(ArgumentError, /Invalid format/)
  end

  it 'should raise on an invalid service' do
    expect { subject.parse(%w[--service blah]) }.to raise_error(ArgumentError, /Invalid service/)
  end

  it 'should run' do
    expect(AwsPublicIps::Checks::Ec2).to receive(:run).and_return([{
      id: 'i-0f22d0af796b3cf3a',
      hostname: 'ec2-54-234-208-236.compute-1.amazonaws.com',
      ip_addresses: %w[54.234.208.236]
    }])
    subject.run(['-s', 'ec2'])
  end

  it 'should rescue exceptions' do
    expect(subject).to receive(:check_service).and_raise(StandardError)
    expect(Process).to receive(:exit).with(1)
    subject.run(['-s', 'ec2'])
  end
end
