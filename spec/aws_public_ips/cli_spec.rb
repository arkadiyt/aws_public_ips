# frozen_string_literal: true

describe ::AwsPublicIps::CLI do
  it 'should run' do
    stub_describe_regions
    expect(::AwsPublicIps::Checks::Ec2).to receive(:run).and_return([{
      id: 'i-0f22d0af796b3cf3a',
      hostname: 'ec2-54-234-208-236.compute-1.amazonaws.com',
      ip_addresses: %w[54.234.208.236]
    }])
    expect(::STDOUT).to receive(:puts)
    subject.run(['-s', 'ec2'])
  end

  it 'should rescue exceptions' do
    stub_describe_regions
    expect(subject).to receive(:check_service).and_raise(::StandardError)
    expect(::Process).to receive(:exit).with(1)
    expect(::STDERR).to receive(:puts)
    subject.run(['-s', 'ec2'])
  end

  it 'should print the version' do
    stub_describe_regions
    expect(::STDOUT).to receive(:puts).with(::AwsPublicIps::VERSION)
    expect { subject.run(['--version']) }.to raise_error(::SystemExit)
  end

  it 'should print help' do
    stub_describe_regions
    expect(::STDOUT).to receive(:puts)
    expect { subject.run(['--help']) }.to raise_error(::SystemExit)
  end
end
