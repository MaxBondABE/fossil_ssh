FROM alpine:latest AS builder
RUN apk update && \
    apk upgrade && \
    apk add \
    gcc make \
    linux-headers musl-dev \
    openssl-dev openssl-libs-static \
    zlib-dev zlib-static
WORKDIR /app
COPY config/checksums ./
RUN wget https://fossil-scm.org/home/tarball/210e89a0597f225f49722b096cf5563bf193e920e02a9bd38503a906deacd416/fossil-src-2.20.tar.gz && \
    sha512sum -c checksums && \
    rm checksums && \
    tar -xf fossil-src-2.20.tar.gz && \
    rm fossil-src-2.20.tar.gz && \
    mv fossil-src-2.20 src && \
    ./src/configure --static && \
    make

FROM alpine:latest AS fossil
WORKDIR /app

COPY config/sshd_config /etc/ssh/sshd_config
COPY --from=builder /app/fossil /usr/local/bin
COPY scripts/fossil_wrapper.sh /usr/local/bin
COPY scripts/add_users.sh /usr/local/bin
COPY users ./users
COPY museum ./museum

RUN apk add bash openssh openrc && \
    rc-update add sshd && \
    mkdir -p /run/openrc && \
    touch /run/openrc/softlevel && \
    addgroup scm && \
    chmod ugo+x /usr/local/bin/* && \
    chmod go-w /usr/local/bin/* && \
    chgrp scm ./museum/* && \
    add_users.sh ./users && \
    rmdir users

ENTRYPOINT ["/bin/sh", "-c", "rc-status; rc-service sshd start; while true; do sleep 60; done"]
