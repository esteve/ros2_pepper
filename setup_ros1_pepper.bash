#!/bin/bash

export PYTHONHOME="/home/nao/Python-2.7.13"
export PATH="${PYTHONHOME}/bin:${PATH}"
export LD_LIBRARY_PATH="/home/nao/ros1_dependencies/lib:${PYTHONHOME}/lib:${LD_LIBRARY_PATH}"

source pepper_ros1_ws/install_isolated/setup.bash