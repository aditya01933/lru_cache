FROM ruby:2.7.5

COPY . /var/www/ruby  

WORKDIR /var/www/ruby  

RUN gem install bundler
RUN bundle install
