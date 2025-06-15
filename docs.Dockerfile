FROM ruby:3

WORKDIR /opt/jekyll

ADD ./docs/Gemfile ./
RUN bundle install

ENTRYPOINT bundle exec jekyll serve --host 0.0.0.0 --source ./site
