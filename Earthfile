VERSION 0.6

test:
    FROM +setup-base
    COPY test ./test
    RUN MIX_ENV=test mix test

lint:
    FROM +setup-base
    COPY .formatter.exs ./
    RUN MIX_ENV=test mix deps.unlock --check-unused
    RUN MIX_ENV=test mix clean
    RUN MIX_ENV=test mix compile --warnings-as-errors
    RUN MIX_ENV=test mix lint

setup-base:
    ARG ELIXIR_BASE=1.16.0-erlang-24.2.2-ubuntu-jammy-20231004
    FROM hexpm/elixir:$ELIXIR_BASE
    RUN apt-get update
    RUN apt-get install -y git build-essential
    RUN mix local.rebar --force
    RUN mix local.hex --force
    ENV ELIXIR_ASSERT_TIMEOUT=10000
    WORKDIR /src/nested_lines
    COPY mix.exs mix.lock ./
    RUN MIX_ENV=test mix deps.get
    RUN MIX_ENV=test mix deps.compile
    COPY lib ./lib
    RUN MIX_ENV=test mix compile
