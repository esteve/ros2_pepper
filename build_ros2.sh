#!/bin/bash
PYTHON2_MAJOR_VERSION=2
PYTHON2_MINOR_VERSION=7
PYTHON2_PATCH_VERSION=13

PYTHON2_VERSION=${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.${PYTHON2_PATCH_VERSION}

PYTHON3_MAJOR_VERSION=3
PYTHON3_MINOR_VERSION=6
PYTHON3_PATCH_VERSION=1

PYTHON3_VERSION=${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}.${PYTHON3_PATCH_VERSION}

INSTALL_ROOT=.ros-root

set -euf -o pipefail
set -xv

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

mkdir -p ccache-build/
mkdir -p pepper_ament_ws/src
mkdir -p pepper_ros2_ws/src
mkdir -p ${INSTALL_ROOT}/ros2_inst

cp repos/pepper_ament.repos pepper_ament_ws/
cp repos/pepper_ros2.repos pepper_ros2_ws/
cp ctc-cmake-toolchain.cmake pepper_ros2_ws/

docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -e INSTALL_ROOT=${INSTALL_ROOT} \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}:ro \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  ros2-pepper \
  bash -c "\
    set -euf -o pipefail && \
    set -xv && \
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/lib && \
    export PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin:\${PATH} && \
    cd pepper_ament_ws && \
    vcs import src < pepper_ament.repos && \
    src/ament/ament_tools/scripts/ament.py build \
	    --isolated \
	    --parallel \
      --cmake-args \
	      -DENABLE_TESTING=OFF \
        -DPYTHON_EXECUTABLE=/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin/python3 \
      --"

docker run -it --rm \
  -u $(id -u $USER) \
  -e PYTHON2_VERSION=${PYTHON2_VERSION} \
  -e PYTHON3_VERSION=${PYTHON3_VERSION} \
  -e PYTHON2_MAJOR_VERSION=${PYTHON2_MAJOR_VERSION} \
  -e PYTHON2_MINOR_VERSION=${PYTHON2_MINOR_VERSION} \
  -e PYTHON3_MAJOR_VERSION=${PYTHON3_MAJOR_VERSION} \
  -e PYTHON3_MINOR_VERSION=${PYTHON3_MINOR_VERSION} \
  -e ALDE_CTC_CROSS=/home/nao/ctc \
  -e INSTALL_ROOT=${INSTALL_ROOT} \
  -v ${PWD}/Python-${PYTHON2_VERSION}-host:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:ro \
  -v ${PWD}/Python-${PYTHON3_VERSION}-host:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}:ro \
  -v ${PWD}/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper:ro \
  -v ${PWD}/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}-pepper:ro \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc:ro \
  -v ${PWD}/${INSTALL_ROOT}/ros1_dependencies:/home/nao/${INSTALL_ROOT}/ros1_dependencies:ro \
  -v ${PWD}/${INSTALL_ROOT}/ros1_inst:/home/nao/${INSTALL_ROOT}/ros1_inst:ro \
  -v ${PWD}/${INSTALL_ROOT}/ros2_inst:/home/nao/${INSTALL_ROOT}/ros2_inst:rw \
  -v ${PWD}/pepper_ros1_ws:/home/nao/pepper_ros1_ws \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  -v ${PWD}/pepper_ros2_ws:/home/nao/pepper_ros2_ws \
  ros2-pepper \
  bash -c "\
    export LD_LIBRARY_PATH=/home/nao/ctc/openssl/lib:/home/nao/ctc/zlib/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/lib && \
    export PKG_CONFIG_PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/lib/pkgconfig:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/lib/pkgconfig:/home/nao/${INSTALL_ROOT}/ros1_dependencies/lib/pkgconfig:/home/nao/${INSTALL_ROOT}/ros1_inst/lib/pkgconfig && \
    export PATH=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}/bin:/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin:\${PATH} && \
    source /home/nao/pepper_ament_ws/install_isolated/local_setup.bash && \
    cd pepper_ros2_ws && \
    vcs import src < pepper_ros2.repos && \
    ament build \
      --install-space /home/nao/${INSTALL_ROOT}/ros2_inst \
      --isolated \
      --cmake-args \
        -Dorocos_kdl_DIR=/home/nao/${INSTALL_ROOT}/ros1_inst/share/orocos_kdl \
        -Dnaoqi_libqi_DIR=/home/nao/${INSTALL_ROOT}/ros1_inst/share/naoqi_libqi/cmake \
        -Dnaoqi_libqicore_DIR=/home/nao/${INSTALL_ROOT}/ros1_inst/share/naoqi_libqicore/cmake \
        -DCATKIN_ENABLE_TESTING=OFF \
        -DENABLE_TESTING=OFF \
        -DPYTHON_EXECUTABLE=/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}/bin/python3 \
        -DPYTHON2_LIBRARY=/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper/lib/libpython${PYTHON2_MAJOR_VERSION}.${PYTHON2_MINOR_VERSION}.so \
        -DPYTHON_LIBRARY=/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}-pepper/lib/libpython${PYTHON3_MAJOR_VERSION}.${PYTHON3_MINOR_VERSION}m.so \
        -DPYTHON_SOABI=cpython-36m-i386-linux-gnu \
        -DTHIRDPARTY_Asio=ON \
        -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros2_ws/ctc-cmake-toolchain.cmake \
        -DALDE_CTC_CROSS=/home/nao/ctc \
        -DCMAKE_FIND_ROOT_PATH=\"/home/nao/pepper_ament_ws/install_isolated;/home/nao/${INSTALL_ROOT}/ros2_inst;/home/nao/pepper_ros2_ws/src/eProsima/Fast-RTPS/thirdparty;/home/nao/${INSTALL_ROOT}/Python-${PYTHON2_VERSION}-pepper;/home/nao/${INSTALL_ROOT}/Python-${PYTHON3_VERSION}-pepper;/home/nao/${INSTALL_ROOT}/ros1_dependencies;/home/nao/${INSTALL_ROOT}/ros1_inst;/home/nao/${INSTALL_ROOT}/ros2_inst;/home/nao/${INSTALL_ROOT}/ros2_inst/fastcdr;/home/nao/ctc\" \
      --"
cp ${PWD}/setup_ros2_pepper.bash ${PWD}/${INSTALL_ROOT}/setup_ros2_pepper.bash
