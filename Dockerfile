FROM ruby:2.3.1
ENV APP_FOLDER /wundercoach_web
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl sudo mysql-client libmysqlclient-dev
RUN mkdir ${APP_FOLDER}
WORKDIR ${APP_FOLDER}
ADD . ${APP_FOLDER}
RUN bundle install
CMD ["/bin/bash"]