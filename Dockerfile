FROM ubuntu:22.04 AS qt-base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y --no-install-recommends \
    bison build-essential clang flex gperf \
    libatspi2.0-dev libbluetooth-dev libclang-dev libcups2-dev libdrm-dev \
    libegl1-mesa-dev libfontconfig1-dev libfreetype6-dev \
    libgstreamer1.0-dev libhunspell-dev libnss3-dev libopengl-dev \
    libpulse-dev libssl-dev libts-dev libx11-dev libx11-xcb-dev \
    libxcb-glx0-dev libxcb-icccm4-dev libxcb-image0-dev \
    libxcb-keysyms1-dev libxcb-randr0-dev libxcb-render-util0-dev \
    libxcb-shape0-dev libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev \
    libxcb-xfixes0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb1-dev \
    libxcomposite-dev libxcursor-dev libxdamage-dev libxext-dev \
    libxfixes-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libxkbfile-dev libxrandr-dev libxrender-dev libxshmfence-dev \
    libxshmfence1 llvm ninja-build nodejs python-is-python3 python3-html5lib \
    python3 wget cmake llvm-dev locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

FROM qt-base as qt-build
WORKDIR /opt

RUN wget https://download.qt.io/official_releases/qt/6.4/6.4.3/single/qt-everywhere-src-6.4.3.tar.xz --no-check-certificate


RUN tar xf qt-everywhere-src-6.4.3.tar.xz && \
    rm qt-everywhere-src-6.4.3.tar.xz && \
    cd  qt-everywhere-src-6.4.3 && \
    ./configure \
             -confirm-license -opensource \
             -skip  qtwebengine \
             -xcb \
             -nomake examples -nomake tests  \
         -prefix "/usr/local/Qt6"

WORKDIR /opt/qt-everywhere-src-6.4.3
RUN cmake --build . --parallel && \
    cmake --install .

RUN cmake --build . --target docs && \
    cmake --build . --target install_docs

FROM qt-base as qt-final
COPY --from=qt-build /usr/local/Qt6 /usr/local/Qt6

#ARG USER=admin
#ARG UID=9999
#ARG GID=9999
#
## Create the user with the given UID/GID
#RUN groupadd -g $GID -o $USER && useradd -m -u $UID -g $GID -o -s /bin/bash $USER
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
#    && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY dev-entrypoint.sh /
