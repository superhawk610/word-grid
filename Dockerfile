FROM swift:latest

RUN apt-get -q update && \
    apt-get install -y libcairo2-dev

WORKDIR /app
