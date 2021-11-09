ARG BASE_IMAGE=alpine:latest
#####################################
FROM ${BASE_IMAGE} as header
#####################################
LABEL org.opencontainers.image.source https://github.com/${PROFILE_NAME}/${PROJECT_NAME}
LABEL org.opencontainers.image.description Dockerized Statoshi.info node
# linux-headers for futex.h in Qt depends build
# qt5-qttools-dev for lrelease
#COPY conf/opt/statsd/config/ /opt/defaultconf/statsd/config/

RUN apk update && apk upgrade && apk ${VERBOSE} ${NOCACHE} --update add \
    autoconf \
    automake \
    bash-completion \
    bison \
    #busybox \
    boost-dev \
    #core-utils \
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
    #mingw-w64-gcc \
    miniupnpc-dev \
    #musl \
    patch \
    perl \
    pkgconfig \
    python3 \
    python3-dev \
    qt5-qtbase-dev \
    qt5-qttools-dev \
    sqlite \
    valgrind \
    vim \
    zeromq-dev
RUN apk update && apk upgrade
RUN apk add ${VERBOSE} ${NOCACHE} \
    autoconf \
    automake \
    binutils \
    ca-certificates \
    cmake \
    curl \
    doxygen \
    git \
    libtool \
    make \
    patch \
    pkgconfig \
    python3 \
    py3-psutil \
    vim

RUN apk add ${VERBOSE} ${NOCACHE} \
    g++ \
    build-base \
    boost-libs \
    libgcc \
    libstdc++ \
    musl \
    boost-system \
    boost-build \
    boost-dev \
    openssl-dev \
    libevent-dev \
    libzmq \
    zeromq-dev \
    protobuf-dev \
    linux-headers \
    libbz2 \
    libcap-dev \
    librsvg \
    tiff-tools \
    zlib-dev \
    py3-setuptools \
    bash
RUN apk add libzmq
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install pyzmq

#ARG GIT_SERVER=${GIT_SERVER}
#ARG PROFILE=${PROFILE}
#ARG PROJECT_NAME=${PROJECT_NAME}
#ENV GIT_SERVER=${GIT_SERVER}
#ENV PROFILE=${PROFILE}
#ENV PROJECT_NAME=${PROJECT_NAME}
############################
RUN  mkdir -p /root/.bitcoin
WORKDIR /tmp/statoshi
COPY . /tmp/statoshi
COPY ./src/statsd_client.h   /usr/local/include/
COPY ./src/statsd_client.cpp /usr/local/include/
############################
FROM header as build-statoshi
RUN echo
############################
FROM build-statoshi as autogen
############################
ARG NETWORK=${NETWORK}
ENV NETWORK=${NETWORK}
WORKDIR /tmp/statoshi
COPY conf /
COPY ./conf/usr/local/bin/blocknotify /etc/periodic/15min/blocknotify
COPY ./conf/${NETWORK}.conf /root/.bitcoin/bitcoin.conf
RUN  ./autogen.sh
#########################
FROM autogen as configure
#########################
WORKDIR /tmp/statoshi
RUN ./configure --disable-wallet --disable-tests --disable-hardening --disable-man --enable-util-cli --enable-util-tx --with-gui=no --without-miniupnpc --disable-bench
######################
FROM configure as make
######################
WORKDIR /tmp/statoshi
RUN make -f Makefile
RUN ls /usr/local/include/*
######################
FROM make as install
######################
WORKDIR /tmp/statoshi
RUN mkdir -p /usr/local/bin/
RUN make -f Makefile install
######################
EXPOSE 80 2003-2004 2013-2014 2023-2024 3000 8080 8118 8333 8332 18333 8125 8125/udp 8126 9050 9051
######################
ARG DATADIR=${DATADIR}
#VOLUME ["/etc/nginx", "/opt/statsd/config", "${DATADIR}"]
#RUN make -j $(nproc) install -C ${REPO}/depends
#RUN apk add libzmq
#RUN /usr/bin/python3.8 -m pip install --upgrade pip
#RUN python3 -m pip install pyzmq
###########################
FROM install as statoshi
###########################
#COPY --from=install /usr /usr
###########################
# Micro containers may not be able to compile from source - signed binaries verified here
###########################

#RUN apk add --no-cache gnupg
#RUN gpg --import  /usr/local/bin/randymcmillan.asc
#RUN gpg --refresh-keys
#RUN while read fingerprint keyholder_name; do gpg --keyserver hkps://keys.openpgp.org --recv-keys ${fingerprint}; done <  ${GIT_REPO_NAME}/conf/usr/local/bin/keys.txt
#RUN gpg --verify /usr/local/bin/bitcoind.gpg    /usr/local/bin/bitcoind
#RUN gpg --verify /usr/local/bin/bitcoin-cli.gpg /usr/local/bin/bitcoin-cli
#RUN gpg --verify /usr/local/bin/bitcoin-tx.gpg  /usr/local/bin/bitcoin-tx
#ENTRYPOINT ["entrypoint"]
#CMD ["bitcoind"]
EXPOSE 80 2003-2004 2013-2014 2023-2024 3000 8080 8118 8333 8332 18333 8125 8125/udp 8126 9050 9051
CMD ["bash"]

