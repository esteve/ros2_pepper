#!/bin/bash

set -euf -o pipefail

PYTHON2_VERSION=2.7.13

INSTALL_ROOT=.ros-root

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

docker build -t ros1-pepper -f docker/Dockerfile_ros1 docker/

if [ ! -e "Python-${PYTHON2_VERSION}.tar.xz" ]; then
  wget -cN https://www.python.org/ftp/python/$PYTHON2_VERSION/Python-${PYTHON2_VERSION}.tar.xz
  tar xvf Python-${PYTHON2_VERSION}.tar.xz
fi

mkdir -p ccache-build/
mkdir -p ${PWD}/Python-${PYTHON2_VERSION}-host
mkdir -p ${PWD}/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}

USE_TTY=""
if [ -z "$ROS_PEPPER_CI" ]; then
  USE_TTY="-it"
fi

docker run ${USE_TTY} --rm \
  -u $(id -u) \
  -e INSTALL_ROOT=${INSTALL_ROOT} \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/ccache-build:/home/nao/.ccache \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -e CC \
  -e CPP \
  -e CXX \
  -e RANLIB \
  -e AR \
  -e AAL \
  -e LD \
  -e READELF \
  -e CFLAGS \
  -e CPPFLAGS \
  -e LDFLAGS \
  ros1-pepper \
  bash -c "\
    set -euf -o pipefail && \
    mkdir -p Python-${PYTHON2_VERSION}-src/build-host && \
    cd Python-${PYTHON2_VERSION}-src/build-host && \
    export PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:\${PATH} && \
    ../configure \
      --prefix=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
      --enable-shared \
      --disable-ipv6 \
      ac_cv_file__dev_ptmx=yes \
      ac_cv_file__dev_ptc=no && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    make -j4 install && \
    wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
    /home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg setuptools vcstool numpy rospkg defusedxml netifaces"

docker run ${USE_TTY} --rm \
  -u $(id -u) \
  -e INSTALL_ROOT=${INSTALL_ROOT} \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/ccache-build:/home/nao/.ccache \
  -v ${PWD}/Python-${PYTHON2_VERSION}:/home/nao/Python-${PYTHON2_VERSION}-src \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  ros1-pepper \
  bash -c "\
    set -euf -o pipefail && \
    mkdir -p Python-${PYTHON2_VERSION}-src/build-pepper && \
    cd Python-${PYTHON2_VERSION}-src/build-pepper && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
    export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:\${PATH} && \
    ../configure \
      --prefix=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION} \
      --host=i686-aldebaran-linux-gnu \
      --build=x86_64-linux \
      --enable-shared \
      --disable-ipv6 \
      ac_cv_file__dev_ptmx=yes \
      ac_cv_file__dev_ptc=no && \
    make -j4 && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    export PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:\${PATH} && \
    make install && \
    wget -O - -q https://bootstrap.pypa.io/get-pip.py | /home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/python && \
    /home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin/pip install empy catkin-pkg setuptools vcstool numpy rospkg defusedxml netifaces"
