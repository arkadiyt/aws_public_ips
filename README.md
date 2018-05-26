# aws_public_ips  [![Gem](https://img.shields.io/gem/v/aws_public_ips.svg)](https://rubygems.org/gems/aws_public_ips) [![TravisCI](https://travis-ci.org/arkadiyt/aws_public_ips.svg?branch=master)](https://travis-ci.org/arkadiyt/aws_public_ips/) [![Coverage Status](https://coveralls.io/repos/github/arkadiyt/aws_public_ips/badge.svg?branch=master)](https://coveralls.io/github/arkadiyt/aws_public_ips?branch=master) [![License](https://img.shields.io/github/license/arkadiyt/aws_public_ips.svg)](https://github.com/arkadiyt/aws_public_ips/blob/master/LICENSE.md)

## Table of Contents
- [What's it for](https://github.com/arkadiyt/aws_public_ips#whats-it-for)
- [Quick start](https://github.com/arkadiyt/aws_public_ips#quick-start)
- [CLI reference](https://github.com/arkadiyt/aws_public_ips#cli-reference)
- [Configuration](https://github.com/arkadiyt/aws_public_ips#configuration)
- [IAM permissions](https://github.com/arkadiyt/aws_public_ips#iam-permissions)
- [Changelog](https://github.com/arkadiyt/aws_public_ips#changelog)
- [Contributing](https://github.com/arkadiyt/aws_public_ips#contributing)
- [Getting in touch](https://github.com/arkadiyt/aws_public_ips#getting-in-touch)

### What's it for

aws_public_ips is a tool to fetch all public IP addresses (both IPv4/IPv6) associated with an AWS account.

It can be used as a library and as a CLI, and supports the following AWS services (all with both Classic & VPC flavors):

- APIGateway
- CloudFront
- EC2 (and as a result: ECS, EKS, Beanstalk, Fargate, Batch, & NAT Instances)
- ElasticSearch
- ELB (Classic ELB)
- ELBv2 (ALB/NLB)
- Lightsail
- RDS
- Redshift

If a service isn't listed (S3, ElastiCache, etc) it's most likely because it doesn't have anything to support (i.e. it might not be deployable publicly, it might have all ip addresses resolve to global AWS infrastructure, etc).

### Quick start

Install the gem and run it:
```
$ gem install aws_public_ips

# Uses default ~/.aws/credentials
$ aws_public_ips
52.84.11.13
52.84.11.83
2600:9000:2039:ba00:1a:cd27:1440:93a1
2600:9000:2039:6e00:1a:cd27:1440:93a1

# With a custom profile
$ AWS_PROFILE=production aws_public_ips
52.84.11.159
```

### CLI reference

```
$ aws_public_ips --help
Usage: aws_public_ips [options]
    -s, --services <s1>,<s2>,<s3>    List of AWS services to check. Available services: apigateway,cloudfront,ec2,elasticsearch,elb,elbv2,lightsail,rds,redshift. Defaults to all.
    -f, --format <format>            Set output format. Available formats: json,prettyjson,text. Defaults to text.
    -v, --[no-]verbose               Enable debug/trace output
        --version                    Print version
    -h, --help                       Show this help message
```

### Configuration

For authentication aws_public_ips uses the default [aws-sdk-ruby](https://github.com/aws/aws-sdk-ruby) configuration, meaning that the following are checked in order:
1. Environment variables:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
  - `AWS_PROFILE`
2. Shared credentials files:
  - `~/.aws/credentials`
  - `~/.aws/config`
3. Instance profile via metadata endpoint (if running on EC2, ECS, EKS, or Fargate)

For more information see the AWS SDK [documentation on configuration](https://github.com/aws/aws-sdk-ruby#configuration).

### IAM permissions
To find the public IPs from all AWS services, the minimal policy needed by your IAM user is:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "apigateway:GET",
        "cloudfront:ListDistributions",
        "ec2:DescribeInstances",
        "elasticloadbalancing:DescribeLoadBalancers",
        "lightsail:GetInstances",
        "lightsail:GetLoadBalancers",
        "rds:DescribeDBInstances",
        "redshift:DescribeClusters"
      ],
      "Resource": "*"
    }
  ]
}
```

### Changelog

Please see [CHANGELOG.md](https://github.com/arkadiyt/aws_public_ips/blob/master/CHANGELOG.md). This project follows [semantic versioning](https://semver.org/).

### Contributing

Please see [CONTRIBUTING.md](https://github.com/arkadiyt/aws_public_ips/blob/master/CONTRIBUTING.md).

### Getting in touch

Feel free to tweet or direct message me: [@arkadiyt](https://twitter.com/arkadiyt)
