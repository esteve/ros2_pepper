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

mkdir -p ${INSTALL_ROOT}/ros1_dependencies
mkdir -p ros1_dependencies_sources/src
cp ros1_dependencies.repos ros1_dependencies_sources/

docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:ro \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host:ro \
  -v ${PWD}/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws:ro \
  -v ${PWD}/ros1_dependencies_sources:/home/nao/ros1_dependencies_sources:rw \
  -v ${PWD}/${INSTALL_ROOT}/ros1_dependencies:/home/nao/${INSTALL_ROOT}/ros1_dependencies:rw \
  ros1-pepper \
  bash -c "\
        export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib && \
        export PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:$PATH && \
				export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/home/nao/${INSTALL_ROOT}/ros1_dependencies/lib/pkgconfig && \
        cd /home/nao/ros1_dependencies_sources && \
        vcs import src < ros1_dependencies.repos && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/console_bridge && \
        cd /home/nao/ros1_dependencies_sources/build/console_bridge && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        ../../src/console_bridge && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/poco && \
        cd /home/nao/ros1_dependencies_sources/build/poco && \
        cmake \
        -DWITH_QT=OFF \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        ../../src/poco && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/urdfdom_headers && \
        cd /home/nao/ros1_dependencies_sources/build/urdfdom_headers && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        ../../src/urdfdom_headers && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/urdfdom && \
        cd /home/nao/ros1_dependencies_sources/build/urdfdom && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/${INSTALL_ROOT}/ros1_dependencies;/home/nao/ctc\" \
        ../../src/urdfdom && \
        make -j4 install && \
        mkdir -p /home/nao/ros1_dependencies_sources/build/tinyxml2 && \
        cd /home/nao/ros1_dependencies_sources/build/tinyxml2 && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/${INSTALL_ROOT}/ros1_dependencies;/home/nao/ctc\" \
        ../../src/tinyxml2 && \
        make -j4 install&& \
        \
        mkdir -p /home/nao/ros1_dependencies_sources/build/SDL && \
        cd /home/nao/ros1_dependencies_sources/src/SDL && \
        ./autogen.sh && \
        cd /home/nao/ros1_dependencies_sources/build/SDL && \
        CC=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cc\
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
        ../../src/SDL/configure \
        --prefix=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        --host=i686-aldebaran-linux-gnu \
        --build=x86_64-linux \
        --enable-shared && \
        make -j4 install &&\
				\
				mkdir -p /home/nao/ros1_dependencies_sources/build/SDL_image && \
        export PATH=$PATH:/home/nao/${INSTALL_ROOT}/ros1_dependencies/bin && \
        cd /home/nao/ros1_dependencies_sources/build/SDL_image && \
        CC=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cc\
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
        ../../src/SDL_image/configure \
        --prefix=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        --host=i686-aldebaran-linux-gnu \
        --build=x86_64-linux \
        --enable-shared && \
        make -j4 install && \
        \
				mkdir -p /home/nao/ros1_dependencies_sources/build/hdf5 && \
        export PATH=$PATH:/home/nao/${INSTALL_ROOT}/ros1_dependencies/bin && \
				cd /home/nao/ros1_dependencies_sources/build/hdf5 && \
				CC=/home/nao/ctc/bin/i686-aldebaran-linux-gnu-cc\
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
        ../../src/hdf5/configure \
        --prefix=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        --host=i686-aldebaran-linux-gnu \
        --build=x86_64-linux \
        --enable-shared && \
        make -j4 install &&\
        \
				mkdir -p /home/nao/ros1_dependencies_sources/build/bullet && \
        cd /home/nao/ros1_dependencies_sources/build/bullet && \
        cmake  \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
        -BUILD_CPU_DEMOS=OFF \
        -DBUILD_SHARED_LIBS=ON \
         ../../src/bullet3 && \
        make -j4 install && \
        \
        mkdir -p /home/nao/ros1_dependencies_sources/build/Yaml-cpp && \
        cd /home/nao/ros1_dependencies_sources/build/Yaml-cpp && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
        -DBUILD_SHARED_LIBS=ON \
         ../../src/Yaml-cpp && \
        make -j4 install &&\
				\
				mkdir -p /home/nao/ros1_dependencies_sources/build/eigen3 && \
				cd /home/nao/ros1_dependencies_sources/build/eigen3 && \
				cmake \
				-DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
				-DALDE_CTC_CROSS=/home/nao/ctc \
				-DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
				-DBUILD_SHARED_LIBS=ON \
				-DCMAKE_CXX_COMPILER_ID=GNU \
				 ../../src/eigen3 && \
				make -j4 install &&\
				\
        mkdir -p /home/nao/ros1_dependencies_sources/build/qhull && \
        cd /home/nao/ros1_dependencies_sources/build/qhull && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
        -DBUILD_SHARED_LIBS=ON \
				-DBUILD_TEST=OFF \
         ../../src/qhull && \
        make -j4 install && \
				\
        mkdir -p /home/nao/ros1_dependencies_sources/build/flann && \
        cd /home/nao/ros1_dependencies_sources/build/flann && \
        cmake \
        -DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
        -DBUILD_SHARED_LIBS=ON \
				-DBUILD_TEST=OFF \
				-DBUILD_PYTHON_BINDINGS=OFF \
				-DBUILD_MATLAB_BINDINGS=OFF \
         ../../src/flann && \
        make -j4 install && \
				\
				mkdir -p /home/nao/ros1_dependencies_sources/build/pcl && \
				cd /home/nao/ros1_dependencies_sources/build/pcl && \
				cmake \
				-DCMAKE_INSTALL_PREFIX=/home/nao/${INSTALL_ROOT}/ros1_dependencies \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
				-DALDE_CTC_CROSS=/home/nao/ctc \
				-DCMAKE_FIND_ROOT_PATH=\"/home/nao/ros1_dependencies;/home/nao/ctc\" \
				-DCMAKE_MODULE_PATH=\"/home/nao/ctc/\" \
				-DBUILD_SHARED_LIBS=ON \
				-DWITH_VTK=OFF \
				-DWITH_QT=OFF \
				-DBUILD_segmentation=ON\
				-DBUILD_surface=ON\
				-Wno-dev \
				 ../../src/pcl && \
				make -j4 install \
"
