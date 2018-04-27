#!/bin/bash
PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=13

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}

PYTHON3_MAJOR_VERSION=3
PYTHON3_MINOR_VERSION=6
PYTHON3_PATCH_VERSION=1

PYTHON3_VERSION=${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}.${PYTHON3_PATCH_VERSION}

HOST_INSTALL_ROOT="${PEPPER_ROS_BASE_ROOT:-${PWD}}/"System
PEPPER_INSTALL_ROOT=System

set -euf -o pipefail
set -xv

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

mkdir -p ccache-build/
mkdir -p pepper_ament_ws/src
mkdir -p pepper_ros2_ws/src
mkdir -p ${HOST_INSTALL_ROOT}/ros2_inst

cp repos/pepper_ament.repos pepper_ament_ws/
cp repos/pepper_ros2.repos pepper_ros2_ws/
cp ctc-cmake-toolchain.cmake pepper_ros2_ws/

USE_TTY=""
if [ -z "$ROS_PEPPER_CI" ]; then
  USE_TTY="-it"
fi

docker run ${USE_TTY} --rm \
  -u $(id -u) \
  -e HOME=/home/nao \
  -e CCACHE_DIR=/home/nao/.ccache \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -e PEPPER_INSTALL_ROOT=${PEPPER_INSTALL_ROOT} \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}:ro \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  ros2-pepper \
  bash -c "\
    set -euf -o pipefail && \
    set -xv && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/lib && \
    export PATH=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin:\${PATH} && \
    cd pepper_ament_ws && \
    vcs import src < pepper_ament.repos && \
    src/ament/ament_tools/scripts/ament.py build \
	    --isolated \
	    --parallel \
      --cmake-args \
	      -DENABLE_TESTING=OFF \
        -DPYTHON_EXECUTABLE=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin/python3 \
      --"

docker run ${USE_TTY} --rm \
  -u $(id -u) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -e PYTHON2_MAJOR_VERSION=${PYTHON2_MAJOR_VERSION} \
  -e PYTHON2_MINOR_VERSION=${PYTHON2_MINOR_VERSION} \
  -e PYTHON3_MAJOR_VERSION=${PYTHON3_MAJOR_VERSION} \
  -e PYTHON3_MINOR_VERSION=${PYTHON3_MINOR_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -e PEPPER_INSTALL_ROOT=${PEPPER_INSTALL_ROOT} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:ro \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}:ro \
  -v ${HOST_INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${HOST_INSTALL_ROOT}/Python-${PYTHON3_VERSION}:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${HOST_INSTALL_ROOT}/ros1_dependencies:/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies:ro \
  -v ${HOST_INSTALL_ROOT}/ros1_inst:/home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst:ro \
  -v ${HOST_INSTALL_ROOT}/ros2_inst:/home/nao/${PEPPER_INSTALL_ROOT}/ros2_inst:rw \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  -v ${PWD}/pepper_ros2_ws:/home/nao/pepper_ros2_ws \
  ros2-pepper \
  bash -c "\
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/lib && \
    export PKG_CONFIG_PATH=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib/pkgconfig:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/lib/pkgconfig:/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies/lib/pkgconfig:/home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst/lib/pkgconfig && \
    export PATH=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin:\${PATH} && \
    source /home/nao/pepper_ament_ws/install_isolated/local_setup.bash && \
    cd pepper_ros2_ws && \
    vcs import src < pepper_ros2.repos && \
    ament build \
      --install-space /home/nao/${PEPPER_INSTALL_ROOT}/ros2_inst \
      --isolated \
      --cmake-args \
        -Dorocos_kdl_DIR=/home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst/share/orocos_kdl \
        -Dnaoqi_libqi_DIR=/home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst/share/naoqi_libqi/cmake \
        -Dnaoqi_libqicore_DIR=/home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst/share/naoqi_libqicore/cmake \
        -DCATKIN_ENABLE_TESTING=OFF \
        -DENABLE_TESTING=OFF \
        -DPYTHON_EXECUTABLE=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin/python3 \
        -DPYTHON2_LIBRARY=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper/lib/libpython${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.so \
        -DPYTHON_LIBRARY=/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}-pepper/lib/libpython${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}m.so \
        -DPYTHON_SOABI=cpython-36m-i386-linux-gnu \
        -DTHIRDPARTY_Asio=ON \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros2_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/pepper_ament_ws/install_isolated;/home/nao/${PEPPER_INSTALL_ROOT}/ros2_inst;/home/nao/pepper_ros2_ws/src/eProsima/Fast-RTPS/thirdparty;/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper;/home/nao/${PEPPER_INSTALL_ROOT}/Python-${PYTHON3_VERSION}-pepper;/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies;/home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst;/home/nao/${PEPPER_INSTALL_ROOT}/ros2_inst;/home/nao/${PEPPER_INSTALL_ROOT}/ros2_inst/fastcdr;/home/nao/ctc\" \
      --"
cp ${PWD}/setup_ros2_pepper.bash ${HOST_INSTALL_ROOT}/setup_ros2_pepper.bash
