#!/bin/bash

HOST_INSTALL_ROOT="${PEPPER_ROS_BASE_ROOT:-${PWD}}/"System
PEPPER_INSTALL_ROOT=System

export PYTHONHOME="/home/nao/${PEPPER_INSTALL_ROOT}/Python-2.7.13"
export PATH="${PYTHONHOME}/bin:${PATH}"
export LD_LIBRARY_PATH="/home/nao/${PEPPER_INSTALL_ROOT}/ros1_dependencies/lib:${PYTHONHOME}/lib:${LD_LIBRARY_PATH}"
export ROS_IP=$(ip addr show wlan0 | grep -Po '(?<= inet )([0-9]{1,3}.){3}[0-9]{1,3}')
export NAO_IP=$ROS_IP
export ROS_MASTER_URI=http://127.0.0.1:11311

source /home/nao/${PEPPER_INSTALL_ROOT}/ros1_inst/setup.bash
