# ros2_pepper


This project aims to execute ROS2 within the Pepper robot. In order to compile ROS2 for the Pepper robot, we need to previously compile ROS1 (due to dependencies with cv_bridge).

Once the project has been compiled, the directories pepper_ros1_ws and pepper_ros2_ws must be copied to the robot.

## Requirements:

You need to install the [NaoQi C++ framework](http://doc.aldebaran.com/2-5/index_dev_guide.html), including the Crosstoolchain. After that, set the appropiate variables, for example, in your ~/.bashrc:

```
export AL_DIR=/home/NaoQi  <-- Or wherever you installed NaoQi
export ALDE_CTC_CROSS=$AL_DIR/ctc-linux64-atom-2.5.2.74
```


## Getting and Compiling
1. Clone the project

```
$ git clone git clone https://github.com/esteve/ros2_pepper.git
$ cd ros2_pepper
```

1. **Prepare the requirements for ROS**. The docker container is created with a compiled version of Python, both for host and robot.

```
./prepare_requirements_ros1.sh
```

1. **Build ROS**.

```
./build_ros1.sh
```

	Note: While all the process, you can get problems with permissions. Check and chown to your user the possible dirs created with root as owner.

1. **Prepare the requirements for ROS2**. Mainly, compiling appropiate version for Python.

```
./prepare_requirements_ros1.sh
```

1. **Build ROS2**.

```
./build_ros2.sh
```

1. **Deploy at robot**. Copy pepper_ros1_ws and pepper_ros2_ws and call each one's install_isolated/setup.sh

1. **Play!!**
