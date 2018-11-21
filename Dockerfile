FROM ruby:2.5.3
RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /bitrise-sample-addon
COPY Gemfile /bitrise-sample-addon/Gemfile
COPY Gemfile.lock /bitrise-sample-addon/Gemfile.lock
RUN gem install bundler --version 1.15.2
RUN bundle _1.15.2_ install

ADD . /bitrise-sample-addon