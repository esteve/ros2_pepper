## Introduction

This project contains a set of patches and scripts to compile and run ROS 1 ROS 2 from within a Pepper robot, without the need of a tethered computer.

## Pre-requirements:

Download and extract the [NaoQi C++ framework](http://doc.aldebaran.com/2-5/index_dev_guide.html) and Softbanks's crosstool chain and point the `AL_DIR` and `ALDE_CTC_CROSS` environment variables to their respective paths:

```
export AL_DIR=/home/NaoQi  <-- Or wherever you installed NaoQi
export ALDE_CTC_CROSS=$AL_DIR/ctc-linux64-atom-2.5.2.74
```

## Prepare cross-compiling environment

We're going to use Docker to set up a container that will compile all the tools for cross-compiling ROS 1 and all of its dependencies. Go to https://https://www.docker.com/community-edition to download it and install it for your Linux distribution.


1. Clone the project's repository

```
$ git clone git clone https://github.com/esteve/ros2_pepper.git
$ cd ros2_pepper
```

1. **Prepare the requirements for ROS**. The following script will create a Docker image and compile Python suitable for both the host and the robot.

```
./prepare_requirements_ros1.sh
```

### Build ROS 1 dependencies

```
./build_ros1_dependencies.sh
```

### Build ROS 1

```
./build_ros1.sh
```

	Note: While all the process, you can get problems with permissions. Check and chown to your user the possible dirs created with root as owner.
