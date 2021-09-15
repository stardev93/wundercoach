FROM ruby:2.3.1

# Install dependencies
#RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get install imagemagick -y
# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www/wundercoach
RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Setting env up
ENV RAILS_ENV='production'
ENV RACK_ENV='production'

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5
#--without development test

# Adding project files
COPY . .
# Need to run it on server.
#RUN bundle exec rake assets:precompile RAILS_ENV=staging

EXPOSE 3000
CMD bundle exec puma -C config/puma.rb