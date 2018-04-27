#!/bin/bash
PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=13

PYTHON3_MAJOR_VERSION=3
PYTHON3_MINOR_VERSION=6
PYTHON3_PATCH_VERSION=1

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}
PYTHON3_VERSION=${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}.${PYTHON3_PATCH_VERSION}

HOST_INSTALL_ROOT="${PEPPER_ROS_BASE_ROOT:-${PWD}}/"System
PEPPER_INSTALL_ROOT=System


set -euf -o pipefail

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

mkdir -p ccache-build/
mkdir -p pepper_ros1_ws/cmake
mkdir -p pepper_ros1_ws/src
cp repos/pepper_ros1.repos pepper_ros1_ws/
cp ctc-cmake-toolchain.cmake pepper_ros1_ws/
cp cmake/eigen3-config.cmake pepper_ros1_ws/cmake/

mkdir -p ${HOST_INSTALL_ROOT}/ros1_dependencies
mkdir -p ros1_dependencies_sources/src
cp repos/ros1_dependencies.repos ros1_dependencies_sources/

USE_TTY=""
if [ -z "$ROS_PEPPER_CI" ]; then
  USE_TTY="-it"
fi

docker run ${USE_TTY} --rm \
  -u $(id -u) \
  -e HOME=/home/nao \
  -e CCACHE_DIR=/home/nao/.ccache \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -e PEPPER_INSTALL_ROOT=${PEPPER_INSTALL_ROOT} \
  -v ${PWD}/ccache-build:/home/nao/.ccache \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:ro \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host:ro \
  -v ${HOST_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws:ro \
  -v ${PWD}/ros1_dependencies_sources:/home/nao/ros1_dependencies_sources:rw \
  -v ${HOST_INSTALL_ROOT}/ros1_dependencies:/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies:rw \
  -v ${PWD}/ros1_dependencies_build_scripts:/home/nao/ros1_dependencies_build_scripts:ro \
  ros1-pepper \
  bash -c "\
    set -eu -o pipefail && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    export PATH=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:$PATH && \
    export PKG_CONFIG_PATH=/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies/lib/pkgconfig && \
    cd /home/nao/ros1_dependencies_sources && \
    vcs import src < ros1_dependencies.repos && \

    for script_file in \$(ls /home/nao/ros1_dependencies_build_scripts/|sort); do
      /home/nao/ros1_dependencies_build_scripts/\$script_file
    done"
