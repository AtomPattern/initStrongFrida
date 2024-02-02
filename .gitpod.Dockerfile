FROM ubuntu:22.04

# SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
# Copyright (c) 2023 fei_cong(https://github.com/feicong/ebpf-course)

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install ruby-dev wget unzip ninja-build build-essential file curl wget git sed \
    lib32stdc++-9-dev libc6-dev-i386 nodejs npm python3-dev python3-pip gcc-multilib g++-multilib \
    gobject-introspection libdwarf-dev libelf-dev libgirepository1.0-dev \
    libglib2.0-dev libjson-glib-dev libsoup-3.0-dev libsqlite3-dev libunwind-dev -y

# RUN gem install fpm -v 1.11.0 --no-document && \
RUN python3 -m pip install -U pip && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install lief ninja meson typing-extensions colorama prompt-toolkit pygments

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 16.20.2

# Install nvm with node and npm
RUN mkdir -p $NVM_DIR && \
    curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default && npm set registry https://registry.npmmirror.com

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip \
    && unzip android-ndk-r25c-linux.zip && rm android-ndk-r25c-linux.zip

ENV ANDROID_NDK_ROOT "/android-ndk-r25c"

# ARG FRIDA_ENV_DIR=/root/frida-env
# WORKDIR ${FRIDA_ENV_DIR}
# COPY patchs ${FRIDA_ENV_DIR}/patchs
# COPY sh ${FRIDA_ENV_DIR}/scripts

RUN git config --global push.default simple \
    && git config --global user.name feicong \
    && git config --global user.email fei_cong@hotmail.com

ENV FRIDA_VERSION 16.1.3
RUN git stash -u \
    && git clean -xdf \
    && git clone --recurse-submodules https://github.com/frida/frida \
    && cd frida \
    && git checkout $FRIDA_VERSION \
    && make core-android-arm64 && file build/frida-android-arm64/bin/frida-server \
    && make core-linux-x86_64 && file build/frida-linux-x86_64/bin/frida-server \
    && cd .. && rm -rf frida

CMD [ "bash" ]
