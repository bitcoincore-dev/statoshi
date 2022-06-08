FROM ubuntu:jammy as base
RUN set -xe; \
apt install -y apt
RUN apt-get -y upgrade
RUN apt-get -y update
ENV DEBIAN_FRONTEND noninteractive
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
	debconf --reinstall \
	bsdmainutils socat \
	apt-utils sudo adduser bash-completion \
	openssh-client openssh-server \
	git make vim python3 python3-pip curl

RUN apt-get install -y \
locales apt-utils bsdmainutils \
sudo adduser bash-completion \
openssh-client openssh-server \
autoconf automake pkg-config \
libtool g++ \
git make vim python3 python3-pip mkdocs
## NOTE: match CI
RUN     apt-get install --no-install-recommends -y \
        automake \
        binutils \
        bsdmainutils \
        ca-certificates \
        cmake \
        curl \
        diffoscope \
        doxygen \
        # gcc-multilib \
        # g++-multilib \
        git \
        libbz2-dev \
        libcap-dev \
        libevent-dev libboost-dev \
        libtinfo5 \
        libtool \
        lbzip2 \
        libz-dev \
        make \
        nsis \
        patch \
        pkg-config \
        python3 \
        python3-setuptools \
        ripgrep \
        vim \
        xz-utils \
        build-essential libtool autotools-dev \
        automake pkg-config bsdmainutils python3 \
        libevent-dev libboost-dev \
        libsqlite3-dev libminiupnpc-dev libnatpmp-dev \
        libzmq3-dev systemtap-sdt-dev \
        libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools \
        qtwayland5 libqrencode-dev  \
               g++-aarch64-linux-gnu \
        binutils-aarch64-linux-gnu \
        g++-arm-linux-gnueabihf \
        binutils-arm-linux-gnueabihf curl \
        binutils-riscv64-linux-gnu \
        g++-riscv64-linux-gnu \
        binutils-gold \
        bsdmainutils pkg-config python3 patch bison \
        g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf \
        g++-aarch64-linux-gnu \
        fzf
        # binutils-aarch64-linux-gnu





RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV DEBIAN_FRONTEND noninteractive

ARG PASSWORD=${PASSWORD}
ENV GIT_DISABLE_UNTRACKED_CACHE=true
ARG HOST_UID=${HOST_UID:-4000}
ARG HOST_USER=${HOST_USER:-nodummy}

ENV SSH_DIR=/home/${HOST_USER}/.ssh
ENV SOCKET_DIR=/home/${HOST_USER}/.ssh-agent
ENV SSH_AUTH_SOCK=/home/${HOST_USER}${SOCKET_DIR}/socket
ENV SSH_AUTH_PROXY_SOCK=/home/${HOST_USER}${SOCKET_DIR}/proxy-socket

VOLUME ${SOCKET_DIR}

RUN chmod 640 /etc/shadow
RUN chmod 4511 /usr/bin/passwd
RUN mkdir -p /var/cache/debconf

RUN if [ -r ~/.ssh/id_rsa ]; then y | ssh-keygen; fi

ARG PASSWORD=changeme

RUN if [ ${HOST_UID} != 0 ]; then adduser --system --disabled-password --ingroup sudo --home /home/${HOST_USER} --uid ${HOST_UID} ${HOST_USER}; fi
RUN echo root:${PASSWORD} | chpasswd
RUN echo ${HOST_USER}:${PASSWORD} | chpasswd
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

ENTRYPOINT ["docker-entrypoint.sh"]

USER ${HOST_USER}
COPY docker/bin /usr/local/bin
COPY docker/opt/healthcheck.sh /opt/healthcheck.sh

WORKDIR /home/${HOST_USER}/statoshi
CMD [ "apt-get instal pkg-config" ]
CMD [ "./autogen.sh" ]
# RUN ./autogen.sh
# CMD [ " CONFIG_SITE=$PWD/depends/aarch64-linux-gnu/share/config.site","./configure ", " --disable-wallet", "--disable-tests ", "--disable-bench", "--disable-man", "--with-gui=no", "--enable-reduce-exports", "LDFLAGS=-static-libstdc++" ]
# CMD [ "./configure ", " --disable-wallet", "--disable-tests ", "--disable-bench", "--disable-man", "--with-gui=no", "--enable-reduce-exports", "LDFLAGS=-static-libstdc++" ]
# CMD [ "./configure ", " --disable-wallet", "--disable-tests ", "--disable-bench", "--disable-man", "--with-gui=no" ]
# RUN ./configure --disable-wallet --disable-tests --disable-bench --disable-man --with-gui=no
# CMD [ "make", "check" ]
CMD [ "ssh-agent" ]
HEALTHCHECK --interval=5s --timeout=1s --retries=3 CMD ["/opt/healthcheck.sh"]

