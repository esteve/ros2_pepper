#! /bin/bash

# Check if ros has been cross-compilled
if [ ! -d "$(pwd)/.ros-root" ]; then
    echo "ERROR: .ros-root directory is not found" 1>&2
    echo "ERROR: please build ros for pepper first" 1>&2
    exit 1
fi
# Receive pepper hostname or ip
echo 'Automatic install script for ros pepper \n'
echo 'Supply peppers hostname or ip address:'
read hostname

# Check if pepper is reachable
reachability=$(ping -c4 $hostname 2>/dev/null | awk '/---/,0' | grep -Po '[0-9]{1,3}(?=% packet loss)')

if [ -z "$reachability" ] || [ "$reachability" == 100 ]; then
    echo "ERROR: $hostname unreachable" 1>&2
    exit 2
fi

# Get ip address of network interface whereover pepper is available.
local_ip=$(ip route get $hostname | grep -Po '(?<=src )([0-9]{1,3}.){3}[0-9]{1,3}')

# Set NAO_IP to ip address at which the robot can be reached
copy_script="sed -e s/NAO_IP=127.0.0.1/NAO_IP=$hostname/g .ros-root/setup_ros1_pepper.bash"
# Set ROS Master URI to ip of which ros is installed (this most probably will te the ros master)
copy_script="$copy_script;sed -e s/ROS_MASTER_URI=http://localhost:11311/ROS_MASTER_URI=http://$local_ip:11311/g .ros-root/setup_ros1_pepper.bash "


echo "scp -R .ros-root nao@$hostname:~/.ros-root"

echo "ssh nao@$hostname $copy_script"
