ARG BASE_IMAGE=docker.io/graphiteapp/graphite-statsd:latest
#####################################
FROM ${BASE_IMAGE} as header
#####################################
LABEL org.opencontainers.image.source https://github.com/${PROFILE_NAME}/${PROJECT_NAME}
LABEL org.opencontainers.image.description Dockerized Statoshi.info node
# linux-headers for futex.h in Qt depends build
# qt5-qttools-dev for lrelease
RUN apk ${VERBOSE} ${NOCACHE} --update add \
    autoconf \
    automake \
    #bash-completion \
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
#FULLBUILD    py3-setuptools
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
FROM install as install-statsd
######################
COPY --from=install /usr /usr
COPY --from=install /etc /etc
#COPY --from=install /root/.bitcoin /root/.bitcoin
RUN apk add nodejs npm
#ARG statsd_version=0.8.6
#ARG statsd_repo=https://github.com/statsd/statsd.git
#WORKDIR /opt
#RUN git clone ${statsd_repo} \
# && cd /opt/statsd \
# && git checkout tags/v${statsd_version} \
# && npm install
######################
FROM install-statsd as config-statsd
#######################
ENV STATSD_INTERFACE tcp/udp
#COPY --from=config-statsd /opt /opt
#COPY --from=config-statsd /usr /usr
#COPY --from=config-statsd /etc /etc
#COPY conf/opt/statsd/config/ /opt/defaultconf/statsd/config/
COPY conf /






ARG DATADIR=${DATADIR}
#VOLUME ["/etc/nginx", "/opt/statsd/config", "${DATADIR}"]





#######################
FROM config-statsd as config-final
#######################
STOPSIGNAL SIGHUP
#RUN make -j $(nproc) install -C ${REPO}/depends
#RUN apk add libzmq
#RUN /usr/bin/python3.8 -m pip install --upgrade pip
#RUN python3 -m pip install pyzmq
###########################
FROM config-final as statoshi
###########################

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
ENTRYPOINT ["entrypoint"]
CMD ["bitcoind"]

