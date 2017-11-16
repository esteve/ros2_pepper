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

mkdir -p console_bridge_ws/src
cp console_bridge.repos console_bridge_ws/

mkdir -p poco_ws/src
cp poco.repos poco_ws/

mkdir -p urdfdom_headers_ws/src
cp urdfdom_headers.repos urdfdom_headers_ws/

mkdir -p urdfdom_ws/src
cp urdfdom.repos urdfdom_ws/

if [ ! -e "console_bridge_ws/install" ]; then

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/console_bridge_ws:/home/nao/console_bridge_ws \
  ros1-pepper \
  bash -c "\
          export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
          export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:$PATH && \
          cd /home/nao/console_bridge_ws && \
          vcs import < console_bridge.repos && \
          mkdir -p build && \
          cd build && \
          cmake \
          -DCMAKE_INSTALL_PREFIX=/home/nao/console_bridge_ws/install \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
          -DALDE_CTC_CROSS=/home/nao/ctc \
          ../console_bridge && \
          make -j4 install"
fi

if [ ! -e "poco_ws/install" ]; then

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/poco_ws:/home/nao/poco_ws \
  ros1-pepper \
  bash -c "\
          export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
          export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:$PATH && \
          cd /home/nao/poco_ws && \
          vcs import < poco.repos && \
          mkdir -p build2 && \
          cd build2 && \
          cmake \
          -DWITH_QT=OFF \
          -DCMAKE_INSTALL_PREFIX=/home/nao/poco_ws/install \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
          -DALDE_CTC_CROSS=/home/nao/ctc \
          ../poco && \
          make -j4 install"
fi

if [ ! -e "urdfdom_headers_ws/install" ]; then

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/console_bridge_ws:/home/nao/console_bridge_ws \
  -v ${PWD}/urdfdom_headers_ws:/home/nao/urdfdom_headers_ws \
  ros1-pepper \
  bash -c "\
          export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
          export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:$PATH && \
          cd /home/nao/urdfdom_headers_ws && \
          vcs import < urdfdom_headers.repos && \
          mkdir -p build && \
          cd build && \
          cmake \
          -DCMAKE_INSTALL_PREFIX=/home/nao/urdfdom_headers_ws/install \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
          -DALDE_CTC_CROSS=/home/nao/ctc \
          ../urdfdom_headers && \
          make -j4 install"
fi

if [ ! -e "urdfdom_ws/install" ]; then

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/console_bridge_ws:/home/nao/console_bridge_ws \
  -v ${PWD}/urdfdom_headers_ws:/home/nao/urdfdom_headers_ws \
  -v ${PWD}/urdfdom_ws:/home/nao/urdfdom_ws \
  ros1-pepper \
  bash -c "\
          export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}-host/lib && \
          export PATH=/home/nao/Python-${PYTHON2_VERSION}-host/bin:$PATH && \
          cd /home/nao/urdfdom_ws && \
          vcs import < urdfdom.repos && \
          mkdir -p build && \
          cd build && \
          cmake \
          -DCMAKE_INSTALL_PREFIX=/home/nao/urdfdom_ws/install \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
          -DALDE_CTC_CROSS=/home/nao/ctc \
          -DCMAKE_FIND_ROOT_PATH=\"/home/nao/console_bridge_ws/install;/home/nao/urdfdom_headers_ws/install;/home/nao/ctc\" \
          ../urdfdom && \
          make -j4 install"
fi

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e PYTHON2_MAJOR_VERSION=${PYTHON2_MAJOR_VERSION} \
  -e PYTHON2_MINOR_VERSION=${PYTHON2_MINOR_VERSION} \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION} \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION}-host \
  -v ${PWD}/Python-${PYTHON3_VERSION}-pepper:/home/nao/Python-${PYTHON3_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/poco_ws:/home/nao/poco_ws \
  -v ${PWD}/console_bridge_ws:/home/nao/console_bridge_ws \
  -v ${PWD}/urdfdom_headers_ws:/home/nao/urdfdom_headers_ws \
  -v ${PWD}/urdfdom_ws:/home/nao/urdfdom_ws \
  ros1-pepper \
  bash -c "\
           export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON2_VERSION}/lib && \
           export PATH=/home/nao/Python-${PYTHON2_VERSION}/bin:$PATH && \
           cd pepper_ros1_ws && \
           vcs import src < pepper_ros1.repos && \
           ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release \
           --cmake-args \
           -DWITH_QT=OFF \
           -DSETUPTOOLS_DEB_LAYOUT=OFF \
           -DCATKIN_ENABLE_TESTING=OFF \
	         -DENABLE_TESTING=OFF \
           -DPYTHON_EXECUTABLE=/home/nao/Python-${PYTHON2_VERSION}/bin/python \
           -DPYTHON_LIBRARY=/home/nao/Python-${PYTHON2_VERSION}-pepper/lib/libpython${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.so \
           -DTHIRDPARTY=ON \
           -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
           -DALDE_CTC_CROSS=/home/nao/ctc \
           -DCMAKE_PREFIX_PATH=\"/home/nao/pepper_ros1_ws/install_isolated\" \
           -DCMAKE_FIND_ROOT_PATH=\"/home/nao/Python-${PYTHON2_VERSION}-pepper;/home/nao/console_bridge_ws/install;/home/nao/poco_ws/install;/home/nao/pepper_ros1_ws/install_isolated;/home/nao/urdfdom_headers_ws/install;/home/nao/urdfdom_ws/install;/home/nao/ctc\" \
           "
