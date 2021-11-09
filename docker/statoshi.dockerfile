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
#FULLBUILD    autoconf \
#FULLBUILD    automake \
    bash-completion \
#FULLBUILD    bison \
    #busybox \
#FULLBUILD    boost-dev \
    #core-utils \
#FULLBUILD    cmake \
    curl \
#FULLBUILD    g++ \
#FULLBUILD    gcc \
#FULLBUILD    git \
#FULLBUILD    libevent-dev \
#FULLBUILD    libqrencode-dev \
#FULLBUILD    libtool \
    linux-headers \
    make \
    #mingw-w64-gcc \
#FULLBUILD    miniupnpc-dev \
#FULLBUILD    #musl \
#FULLBUILD    patch \
#FULLBUILD    perl \
#FULLBUILD    pkgconfig \
#FULLBUILD    python3 \
#FULLBUILD    python3-dev \
#FULLBUILD    qt5-qtbase-dev \
#FULLBUILD    qt5-qttools-dev \
#FULLBUILD    sqlite \
#FULLBUILD    valgrind \
#FULLBUILD    vim \
#FULLBUILD    zeromq-dev
#FULLBUILDRUN apk update && apk upgrade
#FULLBUILDRUN apk add ${VERBOSE} ${NOCACHE} \
#FULLBUILD    autoconf \
#FULLBUILD    automake \
#FULLBUILD    binutils \
#FULLBUILD    ca-certificates \
#FULLBUILD    cmake \
#FULLBUILD    curl \
#FULLBUILD    doxygen \
#FULLBUILD    git \
#FULLBUILD    libtool \
#FULLBUILD    make \
#FULLBUILD    patch \
#FULLBUILD    pkgconfig \
#FULLBUILD    python3 \
#FULLBUILD    py3-psutil \
#FULLBUILD    vim
#FULLBUILD
#FULLBUILDRUN apk add ${VERBOSE} ${NOCACHE} \
#FULLBUILD    g++ \
#FULLBUILD    build-base \
#FULLBUILD    boost-libs \
#FULLBUILD    libgcc \
#FULLBUILD    libstdc++ \
#FULLBUILD    musl \
#FULLBUILD    boost-system \
#FULLBUILD    boost-build \
#FULLBUILD    boost-dev \
#FULLBUILD    openssl-dev \
#FULLBUILD    libevent-dev \
#FULLBUILD    libzmq \
#FULLBUILD    zeromq-dev \
#FULLBUILD    protobuf-dev \
#FULLBUILD    linux-headers \
#FULLBUILD    libbz2 \
#FULLBUILD    libcap-dev \
#FULLBUILD    librsvg \
#FULLBUILD    tiff-tools \
#FULLBUILD    zlib-dev \
#FULLBUILD    py3-setuptools \
    bash
#FULLBUILDRUN apk add libzmq
#FULLBUILDRUN python3 -m ensurepip --upgrade
#FULLBUILDRUN python3 -m pip install pyzmq

#ARG GIT_SERVER=${GIT_SERVER}
#ARG PROFILE=${PROFILE}
#ARG PROJECT_NAME=${PROJECT_NAME}
#ENV GIT_SERVER=${GIT_SERVER}
#ENV PROFILE=${PROFILE}
#ENV PROJECT_NAME=${PROJECT_NAME}
############################
RUN  mkdir -p /root/.bitcoin
WORKDIR /tmp/statoshi
#FULLBUILDCOPY . /tmp/statoshi
#FULLBUILDCOPY ./src/statsd_client.h   /usr/local/include/
#FULLBUILDCOPY ./src/statsd_client.cpp /usr/local/include/
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
#FULLBUILDRUN  ./autogen.sh
#########################
FROM autogen as configure
#########################
WORKDIR /tmp/statoshi
#FULLBUILDRUN ./configure --disable-wallet --disable-tests --disable-hardening --disable-man --enable-util-cli --enable-util-tx --with-gui=no --without-miniupnpc --disable-bench
######################
FROM configure as make
######################
WORKDIR /tmp/statoshi
#FULLBUILDRUN make -f Makefile
#FULLBUILDRUN ls /usr/local/include/*
######################
FROM make as install
######################
WORKDIR /tmp/statoshi
RUN mkdir -p /usr/local/bin/
#FULLBUILDRUN make -f Makefile install
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

