# syntax=docker/dockerfile:experimental

FROM ubuntu:23.04 AS base

LABEL org.opencontainers.image.source https://github.com/jaepil/pytorch-dist

# linux/amd64, linux/arm64, etc.
ARG TARGETPLATFORM
RUN echo "Building docker image for $TARGETPLATFORM architecture"

ARG DEBCONF_NOWARNINGS=yes
ARG DEBIAN_FRONTEND=noninteractive

ARG CCACHE_DIR=/tmp/.cache/.ccache
ARG CCACHE_COMPRESS=1

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends libssl-dev openssl \
    && apt-get install -y --no-install-recommends tzdata software-properties-common \
    && apt-get install -y --no-install-recommends \
        ca-certificates gpg-agent unzip \
        build-essential autoconf binutils-dev libunwind-dev libdw-dev \
        libtool pkg-config ninja-build ccache flex bison uuid-dev libreadline-dev \
        libncursesw5-dev libgdbm-dev libdouble-conversion-dev \
        libz-dev liblz4-dev libbz2-dev liblzma-dev libsnappy-dev libzstd-dev libbrotli-dev \
        libffi-dev libssl-dev openssl libc-ares-dev \
        \
        curl wget git git-lfs python3 python3-venv python3-dev python3-pip \
        \
    && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        apt-get install -y --no-install-recommends libdnnl-dev libmkl-dev; \
    else \
        apt-get install -y --no-install-recommends \
            libblas-dev liblapack-dev libdnnl-dev libarm-compute-dev; \
    fi \
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-Linux-`uname -m`.sh \
    && chmod +x ./cmake-3.24.2-Linux-`uname -m`.sh \
    && ./cmake-3.24.2-Linux-`uname -m`.sh --prefix=/usr --skip-license \
    && rm cmake-3.24.2-Linux-`uname -m`.sh

RUN python3 -m venv $HOME/.venv && . $HOME/.venv/bin/activate \
    && pip --no-cache-dir install pip setuptools wheel \
    && pip --no-cache-dir install astunparse numpy pyyaml typing_extensions future six requests dataclasses pyyaml \
    && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        pip --no-cache-dir install mkl mkl-include; \
    fi

WORKDIR /app/tmp
RUN . $HOME/.venv/bin/activate && git clone --depth 1 -b v2.0.1 https://github.com/pytorch/pytorch.git \
    && cd pytorch && git submodule sync && git submodule update --init --recursive --jobs `nproc --all` \
    && CFLAGS="-Wno-stringop-overread -Wno-incompatible-pointer-types -Wno-sign-compare -Wno-nonnull" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=1 -Wno-unused-result -Wno-uninitialized -Wno-maybe-uninitialized -Wno-nonnull -Wno-strict-aliasing -Wno-deprecated-declarations -Wno-free-nonheap-object" USE_DISTRIBUTED=OFF PYTORCH_BUILD_VERSION=2.0.1 PYTORCH_BUILD_NUMBER=1 python3 setup.py bdist_wheel && cd ..

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
