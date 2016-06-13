FROM elixir:1.2.5

RUN apt-get update -q && \
    apt-get -y install \
      apt-transport-https curl libpq-dev postgresql-client \
    && apt-get clean -y \
    && rm -rf /var/cache/apt/*

# Node.js 6.x
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_6.x jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -q && \
    apt-get install -y nodejs && \
    apt-get clean -y && \
    rm -rf /var/cache/apt/*

# Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /usr/src/app
ENV MIX_ENV prod

# mix deps.get
COPY mix.* /usr/src/app/
RUN mix do deps.get --only prod

# npm install
COPY package.json /usr/src/app/
RUN npm install
RUN mix deps.compile --only prod

# mix compile
COPY . /usr/src/app/
RUN mix compile

# Run
EXPOSE 80
env PORT 80
CMD ["mix", "phoenix.server"]
