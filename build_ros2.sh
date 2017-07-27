#!/bin/bash
PYTHON_VERSION=3.6.1

set -euf -o pipefail
set -xv

if [ -z "$ALDE_CTC_CROSS" ]; then
  echo "Please define the ALDE_CTC_CROSS variable with the path to Aldebaran's Crosscompiler toolchain"
  exit 1
fi

mkdir -p pepper_ament_ws/src
mkdir -p pepper_ros2_ws/src
cp pepper_ament.repos pepper_ament_ws/
cp pepper_ros2.repos pepper_ros2_ws/
cp ctc-cmake-toolchain.cmake pepper_ros2_ws/

docker run -it --rm \
  -v ${PWD}/Python-${PYTHON_VERSION}-host:/home/nao/Python-${PYTHON_VERSION}-host \
  -v ${PWD}/Python-${PYTHON_VERSION}-pepper:/home/nao/Python-${PYTHON_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  ros2-pepper \
  bash -c "set -euf -o pipefail && \
           set -xv && \
           export PATH=/home/nao/Python-${PYTHON_VERSION}-host/bin:\$PATH && \
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
  -e PYTHON_VERSION=${PYTHON_VERSION} \
  -v ${PWD}/Python-${PYTHON_VERSION}-host:/home/nao/Python-${PYTHON_VERSION} \
  -v ${PWD}/Python-${PYTHON_VERSION}-host:/home/nao/Python-${PYTHON_VERSION}-host \
  -v ${PWD}/Python-${PYTHON_VERSION}-pepper:/home/nao/Python-${PYTHON_VERSION}-pepper \
  -v ${ALDE_CTC_CROSS}:/home/nao/ctc \
  -v ${PWD}/pepper_ament_ws:/home/nao/pepper_ament_ws \
  -v ${PWD}/pepper_ros2_ws:/home/nao/pepper_ros2_ws \
  ros2-pepper \
  bash -c "export ALDE_CTC_CROSS=/home/nao/ctc && \
           export PATH=/home/nao/Python-${PYTHON_VERSION}/bin:$PATH && \
           source pepper_ament_ws/install_isolated/local_setup.bash && \
           cd pepper_ros2_ws && \
           vcs import src < pepper_ros2.repos && \
           ament build \
	   --isolated \
	   --parallel \
           --cmake-args \
	   -DENABLE_TESTING=OFF \
           -DPYTHON_EXECUTABLE=/home/nao/Python-${PYTHON_VERSION}/bin/python3 \
           -DPYTHON_LIBRARY=/home/nao/Python-${PYTHON_VERSION}-pepper/lib/libpython3.6m.a \
           -DTHIRDPARTY=ON \
           -DCMAKE_TOOLCHAIN_FILE=/home/nao/pepper_ros2_ws/ctc-cmake-toolchain.cmake \
           -DALDE_CTC_CROSS=/home/nao/ctc \
           -DCMAKE_FIND_ROOT_PATH=\"/home/nao/Python-${PYTHON_VERSION}-pepper;/home/nao/pepper_ament_ws/install_isolated;/home/nao/pepper_ros2_ws/install_isolated;/home/nao/pepper_ros2_ws/src/eProsima/Fast-RTPS/thirdparty\" \
           --"