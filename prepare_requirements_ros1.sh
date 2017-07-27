#!/bin/bash

set -euf -o pipefail

set -xv

PYTHON2_VERSION=2.7.13

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

if [ ! -e "Python-${PYTHON2_VERSION}.tar.xz" ]; then
  wget -cN https://www.python.org/ftp/python/$PYTHON2_VERSION/Python-${PYTHON2_VERSION}.tar.xz
  tar xvf Python-${PYTHON2_VERSION}.tar.xz
fi

mkdir -p ${PWD}/Python-${PYTHON2_VERSION}-pepper

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  ros2-pepper \
  bash -c "set -euf -o pipefail && \
           set -xv && \
           mkdir -p Python-${PYTHON2_VERSION}-src/build-pepper && \
           cd Python-${PYTHON2_VERSION}-src/build-pepper && \
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
           --disable-ipv6 \
           ac_cv_file__dev_ptmx=yes \
           ac_cv_file__dev_ptc=no && \
		   make install && \
       wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/Python-${PYTHON2_VERSION}/bin/python && \
       /home/nao/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg"
