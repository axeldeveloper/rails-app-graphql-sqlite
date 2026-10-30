FROM ruby:3.2.2

WORKDIR /myapp

COPY Gemfile* /myapp/

RUN apt -qq update && apt install -y build-essential


# ARG INSTALL_PYTHON=false

# RUN if [ ${INSTALL_PYTHON} = true ]; then \
#  apt-get -y install python python2.7 python-pip python-dev \
#  && python -m pip install --upgrade pip  \
#  && python -m pip install --upgrade virtualenv \
#;fi


RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  apt-get update -qq && \
  apt-get install -y vim nodejs sqlite3 libsqlite3-dev yarn && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN gem update --system && \
    bundle install

COPY . /myapp

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# ARG DEFAULT_PORT 3000
# EXPOSE ${DEFAULT_PORT}

CMD ["rails", "server", "-b", "0.0.0.0"]
# CMD ["rails", "server", "-b", "127.0.0.1"]