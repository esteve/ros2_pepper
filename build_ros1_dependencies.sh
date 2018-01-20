#!/bin/bash
PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=13

PYTHON3_MAJOR_VERSION=3
PYTHON3_MINOR_VERSION=6
PYTHON3_PATCH_VERSION=1

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}
PYTHON3_VERSION=${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}.${PYTHON3_PATCH_VERSION}

set -euf -o pipefail
set -xv

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

mkdir -p pepper_ros1_ws/cmake
mkdir -p pepper_ros1_ws/src
cp pepper_ros1.repos pepper_ros1_ws/
cp ctc-cmake-toolchain.cmake pepper_ros1_ws/
cp cmake/eigen3-config.cmake pepper_ros1_ws/cmake/

mkdir -p ros1_dependencies
mkdir -p ros1_dependencies_sources/src
cp ros1_dependencies.repos ros1_dependencies_sources/

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}:ro \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host:ro \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws:ro \
  -v ${PWD}/ros1_dependencies_sources:/home/nao/ros1_dependencies_sources:rw \
  -v ${PWD}/ros1_dependencies:/home/nao/ros1_dependencies:rw \
  ros1-pepper \
  bash -c "\
        export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
        export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:$PATH && \
        cd /home/nao/ros1_dependencies_sources && \
        vcs import src < ros1_dependencies.repos && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/console_bridge && \
        cd /home/nao/ros1_dependencies_sources/build/console_bridge && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        ../../src/console_bridge && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/poco && \
        cd /home/nao/ros1_dependencies_sources/build/poco && \
        cmake \
        -DWITH_QT=OFF \
        -DCMAKE_INSTALL_PREFIX=/home/nao/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        ../../src/poco && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/urdfdom_headers && \
        cd /home/nao/ros1_dependencies_sources/build/urdfdom_headers && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        ../../src/urdfdom_headers && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/urdfdom && \
        cd /home/nao/ros1_dependencies_sources/build/urdfdom && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
        ../../src/urdfdom && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/tinyxml2 && \
        cd /home/nao/ros1_dependencies_sources/build/tinyxml2 && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
        ../../src/tinyxml2 && \
        make -j4 install"
