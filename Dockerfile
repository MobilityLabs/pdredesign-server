FROM ruby:2.5.3

RUN apt update && apt upgrade -y
RUN apt install apt-transport-https

RUN curl -sL "https://deb.nodesource.com/gpgkey/nodesource.gpg.key" | apt-key add -
RUN echo "deb https://deb.nodesource.com/node_6.x jessie main" | tee /etc/apt/sources.list.d/nodesource.list

RUN curl -sS "https://dl.yarnpkg.com/debian/pubkey.gpg" | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update

RUN apt install -y postgresql-client

# install yarn and js libraries
RUN apt install -y nodejs
RUN apt install -y yarn

# Bundle install
RUN echo -n "---\nBUNDLE_DISABLE_SHARED_GEMS: \"true\"\nBUNDLE_PATH: \"/code/.bundle\"" > /usr/local/bundle/config

WORKDIR /code

ENTRYPOINT ["sh", "./start.sh"]
