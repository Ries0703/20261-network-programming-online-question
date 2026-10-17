FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        cmake \
        gdb \
        git \
        libcjson-dev \
        libsqlite3-dev \
        make \
        pkg-config \
        python3 \
        python3-tk \
        valgrind \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash appdev \
    && mkdir -p /var/lib/online-testing-app \
    && chown appdev:appdev /var/lib/online-testing-app

USER appdev
WORKDIR /workspace/online-testing-app

CMD ["sleep", "infinity"]
