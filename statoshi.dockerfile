ARG BASE_IMAGE=docker.io/graphiteapp/graphite-statsd:latest
#####################################
FROM ${BASE_IMAGE} as header
#####################################

ENV PROFILE_NAME ${PROFILE_NAME}
ENV PROJECT_NAME ${PROJECT_NAME}
ARG TRIPLET=${TRIPLET}

LABEL maintainer="@RandyMcMillan <randy.lee.mcmillan@gmail.com>"
LABEL org.opencontainers.image.source https://github.com/${PROFILE_NAME}/${PROJECT_NAME}
LABEL org.opencontainers.image.description Dockerized Statoshi.info node
# linux-headers for futex.h in Qt depends build
# qt5-qttools-dev for lrelease
RUN apk ${VERBOSE} ${NOCACHE} --update add \
    autoconf \
    automake \
    bash \
    bison \
    boost-dev \
    cmake \
    curl \
    g++ \
    gcc \
    git \
    libevent-dev \
    libqrencode-dev \
    libtool \
    linux-headers \
    make \
    # mingw-w64-gcc \
    miniupnpc-dev \
    patch \
    perl \
    pkgconfig \
    python3 \
    py3-pip \
    qt5-qtbase-dev \
    qt5-qttools-dev \
    su-exec \
    sqlite \
    valgrind \
    vim #\
    # zeromq-dev

############################
WORKDIR /tmp/statoshi
COPY . /tmp/statoshi
COPY ./src/statsd_client.h   /usr/local/include/
COPY ./src/statsd_client.cpp /usr/local/include/
############################
FROM header as make-depends
# Place Holders
WORKDIR /tmp/statoshi
RUN make download -C depends
# RUN make -f Makefile -C depends
############################
FROM make-depends as autogen
############################
WORKDIR /tmp/statoshi
RUN  ./autogen.sh
#########################
FROM autogen as configure
#########################
WORKDIR /tmp/statoshi
# RUN make -f Makefile -C depends
RUN ./configure --disable-tests --disable-man --disable-bench --with-gui=no --disable-wallet
######################
FROM configure as make
######################
WORKDIR /tmp/statoshi
RUN make -f Makefile
######################
FROM make as install
######################
WORKDIR /tmp/statoshi
RUN mkdir -p /usr/local/bin/
RUN make -f Makefile install
######################
# FROM ${BASE_IMAGE} as statoshi
######################
#REF: https://raw.githubusercontent.com/graphite-project/docker-graphite-statsd/master/Dockerfile
ARG NETWORK=${NETWORK}
# COPY --from=install /usr /usr
# COPY --from=install /var /var
# COPY --from=install /opt /opt
# COPY --from=install /etc /etc
RUN  mkdir -p /root/.bitcoin
COPY ./conf/usr/local/bin/entrypoint /usr/local/bin/entrypoint
COPY ./conf/usr/local/bin/blocknotify /etc/periodic/15min/blocknotify
COPY ./conf/${NETWORK}.conf /root/.bitcoin/bitcoin.conf
RUN  rm -rf /var/cache/apk/*

# RUN apk add libzmq
# RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install pyzmq twisted

EXPOSE ${PORT} 2003-2004 2013-2014 2023-2024 3000 8080 8118 8333 8332 ${NODE_PORT} 8125 8125/udp 8126 9050 9051
# ENV STATSD_INTERFACE udp
ENV DATADIR /root/.bitcoin
# VOLUME $DATADIR

STOPSIGNAL SIGHUP

ENTRYPOINT ["entrypoint"]
