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

mkdir -p pepper_ament_ws/src
mkdir -p pepper_ros2_ws/src
cp repos/pepper_ament.repos pepper_ament_ws/
cp repos/pepper_ros2.repos pepper_ros2_ws/
cp ctc-cmake-toolchain.cmake pepper_ros2_ws/

docker run -it --rm \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION}-host \
  -v ${PWD}/Python-${PYTHON3_VERSION}-pepper:/home/nao/Python-${PYTHON3_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  ros2-pepper \
  bash -c "\
    set -euf -o pipefail && \
    set -xv && \
    export PATH=/home/nao/Python-${PYTHON3_VERSION}-host/bin:$PATH && \
    cd pepper_ament_ws && \
    vcs import src < pepper_ament.repos && \
    src/ament/ament_tools/scripts/ament.py build \
	    --isolated \
	    --parallel \
      --cmake-args \
	      -DENABLE_TESTING=OFF \
        -DPYTHON_EXECUTABLE=/home/nao/Python-${PYTHON3_VERSION}-host/bin/python3 \
      --"

docker run -it --rm \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/Python-${PYTHON2_VERSION}-host \
  -v ${PWD}/Python-${PYTHON2_VERSION}-pepper:/home/nao/Python-${PYTHON2_VERSION}-pepper \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION} \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/Python-${PYTHON3_VERSION}-host \
  -v ${PWD}/Python-${PYTHON3_VERSION}-pepper:/home/nao/Python-${PYTHON3_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  -v ${PWD}/pepper_ros2_ws:/home/nao/pepper_ros2_ws \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/poco_ws:/home/nao/poco_ws \
  -v ${PWD}/console_bridge_ws:/home/nao/console_bridge_ws \
  -v ${PWD}/urdfdom_headers_ws:/home/nao/urdfdom_headers_ws \
  -v ${PWD}/urdfdom_ws:/home/nao/urdfdom_ws \
  -v ${PWD}/tinyxml2_ws:/home/nao/tinyxml2_ws \
  ros2-pepper \
  bash -c "\
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/Python-${PYTHON3_VERSION}/lib && \
    export PKG_CONFIG_PATH=/home/nao/Python-${PYTHON2_VERSION}-pepper/lib/pkgconfig:/home/nao/Python-${PYTHON3_VERSION}-pepper/lib/pkgconfig:/home/nao/console_bridge_ws/install/lib/pkgconfig:/home/nao/poco_ws/install/lib/pkgconfig:/home/nao/pepper_ros1_ws/install_isolated/lib/pkgconfig:/home/nao/urdfdom_headers_ws/install/lib/pkgconfig:/home/nao/urdfdom_ws/install/lib/pkgconfig:/home/nao/tinyxml2_ws/install/lib/pkgconfig:/home/nao/opencv2/lib/pkgconfig && \
    export ALDE_CTC_CROSS=/home/nao/ctc && \
    export PATH=/home/nao/Python-${PYTHON3_VERSION}/bin:$PATH && \
    source /home/nao/pepper_ament_ws/install_isolated/local_setup.bash && \
    cd pepper_ros2_ws && \
    vcs import src < pepper_ros2.repos && \
    ament build \
	    --isolated \
	    --parallel \
      --cmake-args \
        -Dorocos_kdl_DIR=/home/nao/pepper_ros1_ws/install_isolated/share/orocos_kdl \
        -Dnaoqi_libqi_DIR=/home/nao/pepper_ros1_ws/install_isolated/share/naoqi_libqi/cmake \
        -Dnaoqi_libqicore_DIR=/home/nao/pepper_ros1_ws/install_isolated/share/naoqi_libqicore/cmake \
        -DCATKIN_ENABLE_TESTING=OFF \
	      -DENABLE_TESTING=OFF \
        -DPYTHON_EXECUTABLE=/home/nao/Python-${PYTHON3_VERSION}/bin/python3 \
        -DPYTHON2_LIBRARY=/home/nao/Python-${PYTHON2_VERSION}-pepper/lib/libpython${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.so \
        -DPYTHON_LIBRARY=/home/nao/Python-${PYTHON3_VERSION}-pepper/lib/libpython${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}m.so \
        -DTHIRDPARTY=ON \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros2_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/Python-${PYTHON3_VERSION}-pepper;/home/nao/poco_ws/install;/home/nao/console_bridge_ws/install;/home/nao/urdfdom_headers_ws/install;/home/nao/urdfdom_ws/install;/home/nao/pepper_ament_ws/install_isolated;/home/nao/pepper_ros2_ws/install_isolated;/home/nao/pepper_ros2_ws/src/eProsima/Fast-RTPS/thirdparty;/home/nao/ctc\" \
      --"
