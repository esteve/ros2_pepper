#!/bin/bash

export PYTHONHOME="/home/nao/ros-root/Python-2.7.13"
export PATH="${PYTHONHOME}/bin:${PATH}"
export LD_LIBRARY_PATH="/home/nao/ros-root/ros1_dependencies/lib:${PYTHONHOME}/lib:${LD_LIBRARY_PATH}"

source /home/nao/ros-root/ros1_inst/setup.bash
