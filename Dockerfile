FROM ruby:2.6.5-alpine

USER nobody

RUN gem install aws_public_ips

CMD aws_public_ips
