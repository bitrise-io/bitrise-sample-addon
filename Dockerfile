FROM ruby:2.5.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /bitrise-sample-addon
WORKDIR /bitrise-sample-addon
COPY Gemfile /bitrise-sample-addon/Gemfile
COPY Gemfile.lock /bitrise-sample-addon/Gemfile.lock
RUN bundle install
COPY . /bitrise-sample-addon