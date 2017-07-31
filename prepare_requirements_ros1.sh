#!/bin/bash

set -euf -o pipefail

set -xv

PYTHON2_VERSION=2.7.13

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

docker build -t ros1-pepper -f docker/Dockerfile_ros1 docker/

if [ ! -e "Python-${PYTHON2_VERSION}.tar.xz" ]; then
  wget -cN https://www.python.org/ftp/python/$PYTHON2_VERSION/Python-${PYTHON2_VERSION}.tar.xz
  tar xvf Python-${PYTHON2_VERSION}.tar.xz
fi

mkdir -p ${PWD}/Python-${PYTHON2_VERSION}-host
mkdir -p ${PWD}/Python-${PYTHON2_VERSION}-pepper

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  ros1-pepper \
  bash -c "set -euf -o pipefail && \
           set -xv && \
           mkdir -p Python-${PYTHON2_VERSION}-src/build-host && \
           cd Python-${PYTHON2_VERSION}-src/build-host && \
           export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:$PATH && \
           ../configure \
           --prefix=/home/nao/Python-${PYTHON2_VERSION}-host \
           --enable-shared \
           --disable-ipv6 \
           ac_cv_file__dev_ptmx=yes \
           ac_cv_file__dev_ptc=no && \
       export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
		   make install && \
       wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/Python-${PYTHON2_VERSION}-host/bin/python && \
       /home/nao/Python-${PYTHON2_VERSION}-host/bin/pip install empy catkin-pkg setuptools vcstool numpy"

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  ros1-pepper \
  bash -c "set -euf -o pipefail && \
           set -xv && \
           mkdir -p Python-${PYTHON2_VERSION}-src/build-pepper && \
           cd Python-${PYTHON2_VERSION}-src/build-pepper && \
           export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-pepper/lib && \
           export PATH=/home/nao/Python-${PYTHON2_VERSION}-pepper/bin:$PATH && \
           CC=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cc \
           CPP=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cpp \
           CXX=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-c++ \
           RANLIB=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-ranlib \
           AR=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-ar \
           AAL=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-aal \
           LD=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-ld \
           READELF=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-readelf \
           CFLAGS='-isysroot /home/nao/ctc/i686-aldebaran-linux-gnu/sysroot' \
           CPPFLAGS='-I/home/nao/ctc/zlib/include -I/home/nao/ctc/bzip2/include -I/home/nao/ctc/openssl/include' \
           LDFLAGS='-L/home/nao/ctc/zlib/lib -L/home/nao/ctc/bzip2/lib -L/home/nao/ctc/openssl/lib' \
           ../configure \
           --prefix=/home/nao/Python-${PYTHON2_VERSION}-pepper \
           --host=i686-aldebaran-linux-gnu \
           --build=x86_64-linux \
           --enable-shared \
           --disable-ipv6 \
           ac_cv_file__dev_ptmx=yes \
           ac_cv_file__dev_ptc=no && \
		   make install && \
       wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/Python-${PYTHON2_VERSION}-pepper/bin/python && \
       /home/nao/Python-${PYTHON2_VERSION}-pepper/bin/pip install empy catkin-pkg setuptools vcstool numpy"
