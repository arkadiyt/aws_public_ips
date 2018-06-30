# How to contribute

Thank you for your interest in contributing to aws_public_ips!

### Code of conduct

Please adhere to the [code of conduct](https://github.com/arkadiyt/aws_public_ips/blob/master/CODE_OF_CONDUCT.md).

### Bugs

**Known issues:** Before reporting new bugs, search if your issue already exists in the [open issues](https://github.com/arkadiyt/aws_public_ips/issues).

**Reporting new issues:** Provide a reduced test case with clear reproduction steps.

**Security issues:** If you believe you've found a security issue please disclose it privately first, either through my [vulnerability disclosure program](https://hackerone.com/arkadiyt-projects) on Hackerone or by direct messaging me on [twitter](https://twitter.com/arkadiyt).

### Proposing a change

If you plan on making large changes, please file an issue before submitting a pull request so we can reach agreement on your proposal.

### Sending a pull request

1. Fork this repository
2. Check out a feature branch: `git checkout -b your-feature-branch`
3. Make changes on your branch
4. Add/update tests - this project maintains 100% code coverage
5. Make sure all status checks pass locally:
  - `bundle exec bundler-audit`
  - `bundle exec rubocop`
  - `bundle exec rspec`
6. Submit a pull request with a description of your changes
