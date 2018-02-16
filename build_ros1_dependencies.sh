#!/bin/bash
PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=13

PYTHON3_MAJOR_VERSION=3
PYTHON3_MINOR_VERSION=6
PYTHON3_PATCH_VERSION=1

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}
PYTHON3_VERSION=${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}.${PYTHON3_PATCH_VERSION}

INSTALL_ROOT=.ros-root

set -euf -o pipefail

if [ -z "$ALDE_CTC_CROSS" ]; then
    echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
    exit 1
fi

mkdir -p pepper_ros1_ws/cmake
mkdir -p pepper_ros1_ws/src
cp pepper_ros1.repos pepper_ros1_ws/
cp ctc-cmake-toolchain.cmake pepper_ros1_ws/
cp cmake/eigen3-config.cmake pepper_ros1_ws/cmake/

mkdir -p ${INSTALL_ROOT}/ros1_dependencies
mkdir -p ros1_dependencies_sources/src
cp ros1_dependencies.repos ros1_dependencies_sources/

docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e INSTALL_ROOT=${INSTALL_ROOT} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:ro \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host:ro \
  -v ${PWD}/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws:ro \
  -v ${PWD}/ros1_dependencies_sources:/home/nao/ros1_dependencies_sources:rw \
  -v ${PWD}/${INSTALL_ROOT}/ros1_dependencies:/home/nao/${INSTALL_ROOT}/ros1_dependencies:rw \
  -v ${PWD}/ros1_dependencies_build_scripts:/home/nao/ros1_dependencies_build_scripts:ro \
  ros1-pepper \
  bash -c "\
    set -eu -o pipefail && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
    export PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:$PATH && \
    cd /home/nao/ros1_dependencies_sources && \
    vcs import src < ros1_dependencies.repos && \

    for script_file in \$(ls /home/nao/ros1_dependencies_build_scripts/|sort); do
      /home/nao/ros1_dependencies_build_scripts/\$script_file
    done"
