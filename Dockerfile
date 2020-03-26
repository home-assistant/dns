ARG BUILD_FROM

FROM golang:1.12.7 AS builder

WORKDIR /workspace
ARG BUILD_ARCH
ARG COREDNS_VERSION

# Build
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        make \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 -b ${COREDNS_VERSION} https://github.com/coredns/coredns \
    && cd coredns \
    && echo "alternate:github.com/coredns/alternate" >> plugin.cfg \
    && \
        if [ "${BUILD_ARCH}" = "armhf" ]; then \
            make coredns SYSTEM="GOOS=linux GOARM=6 GOARCH=arm"; \
        elif [ "${BUILD_ARCH}" = "armv7" ]; then \
            make coredns SYSTEM="GOOS=linux GOARM=7 GOARCH=arm"; \
        elif [ "${BUILD_ARCH}" = "aarch64" ]; then \
            make coredns SYSTEM="GOOS=linux GOARCH=arm64"; \
        elif [ "${BUILD_ARCH}" = "i386" ]; then \
            make coredns SYSTEM="GOOS=linux GOARCH=386"; \
        elif [ "${BUILD_ARCH}" = "amd64" ]; then \
            make coredns SYSTEM="GOOS=linux GOARCH=amd64"; \
        else \
            exit 1; \
        fi \
    && cp -f coredns /workspace/coredns_binary \
    && rm -rf /workspace/coredns/


FROM ${BUILD_FROM}

WORKDIR /config
COPY --from=builder /workspace/coredns_binary /usr/bin/coredns

# rootfs
COPY rootfs /
