#!/bin/bash
PYTHON2_VERSION=2.7.13
PYTHON3_VERSION=3.6.1

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
mkdir -p poco_ws/src

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/console_bridge_ws:/home/nao/console_bridge_ws \
  ros2-pepper \
  bash -c "\
          cd /home/nao/console_bridge_ws/src && \
          git clone https://github.com/ros/console_bridge.git && \
          mkdir -p build && \
          cd build && \
          cmake \
          -DCMAKE_INSTALL_PREFIX=/home/nao/console_bridge_ws/install \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
          -DALDE_CTC_CROSS=/home/nao/ctc \
          .."

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/poco_ws:/home/nao/poco_ws \
  ros2-pepper \
  bash -c "\
          cd /home/nao/poco_bridge_ws/src && \
          git clone -b poco-1.7.8p3-release https://github.com/pocoproject/poco.git && \
          mkdir -p build2 && \
          cd build2 && \
          cmake \
          -DWITH_QT=OFF
          -DCMAKE_INSTALL_PREFIX=/home/nao/poco_ws/install \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
          -DALDE_CTC_CROSS=/home/nao/ctc \
          .."

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION} \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION}-host \
  -v ${PWD}/Python-${PYTHON3_VERSION}-pepper:/home/nao/Python-${PYTHON3_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  ros2-pepper \
  bash
  #bash -c "\
           cd pepper_ros1_ws && \
           vcs import src < pepper_ros1.repos && \
           ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release \
           --cmake-args \
           -DSETUPTOOLS_DEB_LAYOUT=OFF \
           -DCATKIN_ENABLE_TESTING=OFF \
	         -DENABLE_TESTING=OFF \
           -DPYTHON_EXECUTABLE=/home/nao/Python-${PYTHON2_VERSION}/bin/python \
           -DPYTHON_LIBRARY=/home/nao/Python-${PYTHON2_VERSION}-pepper/lib/libpython2.7.a \
           -DTHIRDPARTY=ON \
           -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros1_ws/ctc-cmake-toolchain.cmake \
           -DALDE_CTC_CROSS=/home/nao/ctc \
           -DCMAKE_PREFIX_PATH=/home/nao/pepper_ros1_ws/install_isolated \
           -DCMAKE_FIND_ROOT_PATH=\"/home/nao/Python-${PYTHON2_VERSION}-pepper;/home/nao/pepper_ros1_ws/install_isolated\"

                      # export PATH=/home/nao/Python-${PYTHON2_VERSION}/bin:/home/nao/Python-${PYTHON3_VERSION}/bin:$PATH && \
