#!/bin/bash

set -euf -o pipefail

set -xv

PYTHON3_VERSION=3.6.1

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

docker build -t ros2-pepper -f docker/Dockerfile_ros2 docker/

if [ ! -e "Python-${PYTHON3_VERSION}.tar.xz" ]; then
  wget -cN https://www.python.org/ftp/python/$PYTHON3_VERSION/Python-${PYTHON3_VERSION}.tar.xz
fi

if [ ! -e "Python-${PYTHON3_VERSION}" ]; then
  tar xvf Python-${PYTHON3_VERSION}.tar.xz
fi

mkdir -p ${PWD}/Python-${PYTHON3_VERSION}-pepper
mkdir -p ${PWD}/Python-${PYTHON3_VERSION}-host

docker run -it --rm \
  -v ${PWD}/Python-${PYTHON3_VERSION}:/home/nao/Python-${PYTHON3_VERSION}-src \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION}-host \
  ros2-pepper \
  bash -c "set -euf -o pipefail && \
           set -xv && \
           pwd && \
           mkdir -p Python-${PYTHON3_VERSION}-src/build-host && \
           cd Python-${PYTHON3_VERSION}-src/build-host && \
           ../configure \
           --prefix=/home/nao/Python-${PYTHON3_VERSION}-host && \
           make install &&
       export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON3_VERSION}-host/lib && \
       wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/Python-${PYTHON3_VERSION}-host/bin/python3 && \
		   /home/nao/Python-${PYTHON3_VERSION}-host/bin/pip3 install empy catkin-pkg setuptools vcstool pyparsing"

docker run -it --rm \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -v ${PWD}/Python-${PYTHON3_VERSION}:/home/nao/Python-${PYTHON3_VERSION}-src \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION}-host \
  -v ${PWD}/Python-${PYTHON3_VERSION}-pepper:/home/nao/Python-${PYTHON3_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  ros2-pepper \
  bash -c "set -euf -o pipefail && \
           set -xv && \
           mkdir -p Python-${PYTHON3_VERSION}-src/build-pepper && \
           cd Python-${PYTHON3_VERSION}-src/build-pepper && \
           export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON3_VERSION}-pepper/lib && \
           export PATH=/home/nao/Python-${PYTHON3_VERSION}-host/bin:$PATH && \
           CC=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cc \
           CPP=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cpp \
           CXX=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-c++ \
           RANLIB=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-ranlib \
           AR=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-ar \
           AAL=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-aal \
           LD=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-ld \
           READELF=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-readelf \
           CFLAGS='-isysroot /home/nao/ctc/i686-aldebaran-linux-gnu/sysroot' \
           ../configure \
           --prefix=/home/nao/Python-${PYTHON3_VERSION}-pepper \
           --host=i686-aldebaran-linux-gnu \
           --build=x86_64-linux \
           --enable-shared \
           --disable-ipv6 \
           ac_cv_file__dev_ptmx=yes \
           ac_cv_file__dev_ptc=no && \
		   make install"
