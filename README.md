## Introduction

This project contains a set of patches and scripts to compile and run ROS 1 ROS 2 from within a Pepper robot, without the need of a tethered computer.

## Pre-requirements:

Download and extract the [NaoQi C++ framework](http://doc.aldebaran.com/2-5/index_dev_guide.html) and Softbanks's crosstool chain and point the `AL_DIR` and `ALDE_CTC_CROSS` environment variables to their respective paths:

```
export AL_DIR=/home/NaoQi  <-- Or wherever you installed NaoQi
export ALDE_CTC_CROSS=$AL_DIR/ctc-linux64-atom-2.5.2.74
```

## Prepare cross-compiling environment

We're going to use Docker to set up a container that will compile all the tools for cross-compiling ROS and all of its dependencies. Go to https://https://www.docker.com/community-edition to download it and install it for your Linux distribution.


1. Clone the project's repository

```
$ git clone git clone https://github.com/esteve/ros2_pepper.git
$ cd ros2_pepper
```

### Prepare the requirements for ROS

The following script will create a Docker image and compile Python interpreters suitable for both the host and the robot.

```
./prepare_requirements_ros1.sh
```

### Build ROS dependencies

Before we actually build ROS for Pepper, there's a bunch of dependencies we'll need to cross compile which are not available in Softbank's CTC:

- console_bridge
- poco
- tinyxml2
- urdfdom
- urdfdom_headers

```
./build_ros1_dependencies.sh
```

### Build ROS

Finally! Type the following, go grab a coffee and after a while you'll have an entire base ROS distro built for Pepper.

```
./build_ros1.sh
```

### Copy ROS and their dependencies to the robot

By now you should have the following in the current directory:

- Python 2.7 built for Pepper (Python-2.7.13-pepper) and for your host computer (Python-2.7.13-host)
- All the dependencies required by ROS (ros1_dependencies)
- A ROS workspace with ROS Kinetic built for Pepper (pepper\_ros1\_ws)
- A helper script that will set up the ROS workspace in the robot

We're going to copy these to the robot, assuming that your robot is connected to your network

#### Option 1 (automatic):

Running the following script will install .ros-root folder into /home/nao/.ros-root.

Afterwards it will set NAO_IP to the ip address used to access pepper for scp & ssh And it will set ROS_MASTER_URI to the ip address of the machine that is used to install the .ros-root folder into pepper unless specified otherwise.

```
$ ./install.sh
Automatic install script for ros pepper
Supply peppers hostname or ip address:
$ <PEPPER_IP>
Supply roscore hostname or ip address empty for [<Current machine IP>]:
$ <ROSCORE_IP/localhost/empty>
if ssh public keys are not exchanged password will be asked twice
Password:
$ <Pepper user password>
<Many lines of scp output>
Password:
$ <Pepper user password>
```

#### Option 2 (Manual)

type the following:

*Make sure you copy Python to the directory Python-2.7.13, without -pepper*

```
$ scp -r .ros-root nao@IP_ADDRESS_OF_YOUR_ROBOT:.ros-root
```

### Run ROS from within Pepper

Now that we have it all in the robot, let's give it a try:

*SSH into the robot*

```
$ ssh nao@IP_ADDRESS_OF_YOUR_ROBOT
```

*Source (not run) the setup script*

```
$ source .ros-root/setup_ros1_pepper.bash
```

*Start naoqi_driver, note that NETWORK\_INTERFACE may be either wlan0 or eth0, pick the appropriate interface if your robot is connected via wifi or ethernet*

```
$ roslaunch naoqi_driver naoqi_driver.launch nao_ip:=IP_ADDRESS_OF_YOUR_ROBOT roscore_ip:=IP_ADDRESS_OF_YOUR_ROBOT network_interface:=NETWORK_ITERFACE
```

Enjoy!
