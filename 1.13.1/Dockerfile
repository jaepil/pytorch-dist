# syntax=docker/dockerfile:experimental

FROM ubuntu:22.10 AS base

LABEL org.opencontainers.image.source = "https://github.com/deepsearch-hq/pytorch-dist"

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
        libffi-dev libssl-dev openssl libc-ares-dev libdnnl-dev libmkl-dev \
        \
        curl wget git git-lfs python3 python3-dev python3-pip \
        \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-Linux-`uname -m`.sh \
    && chmod +x ./cmake-3.24.2-Linux-`uname -m`.sh \
    && ./cmake-3.24.2-Linux-`uname -m`.sh --prefix=/usr --skip-license \
    && rm cmake-3.24.2-Linux-`uname -m`.sh

RUN pip --no-cache-dir install pip setuptools wheel \
    && pip --no-cache-dir install astunparse numpy pyyaml typing_extensions future six requests dataclasses \
    && pip --no-cache-dir install mkl mkl-include

WORKDIR /app/tmp
RUN git clone --depth 1 -b v1.13.1 https://github.com/pytorch/pytorch.git \
    && cd pytorch && git submodule sync && git submodule update --init --recursive --jobs 0 \
    && CFLAGS="-Wno-stringop-overread -Wno-incompatible-pointer-types -Wno-sign-compare -Wno-nonnull" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=1 -Wno-unused-result -Wno-uninitialized -Wno-maybe-uninitialized -Wno-nonnull -Wno-strict-aliasing -Wno-deprecated-declarations" USE_DISTRIBUTED=OFF PYTORCH_BUILD_VERSION=1.13.1 PYTORCH_BUILD_NUMBER=1 python3 setup.py bdist_wheel && cd ..

RUN git clone https://github.com/deepsearch-hq/pytorch-dist.git \
    && cd pytorch-dist && mkdir 1.13.1 && cd 1.13.1 \
    && cp ../../pytorch/dist/*.whl . \
    && git add *.whl && git commit -m "Add pytorch 1.13.1 wheel" \
    && git push

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
