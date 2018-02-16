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

echo "Supply roscore hostname or ip address empty for [$local_ip]:"
read master_ip
if [ -z "$master_ip" ]; then
    master_ip=$local_ip
fi
# Set ROS Master URI to ip of which ros is installed (this most probably will te the ros master)
copy_script="sed -i.bak 's/^\(export\s*ROS_MASTER_URI\s*=\s*\).*$/\http:\/\/$master_ip:11311/' .ros-root/setup_ros1_pepper.bash"
echo 'if ssh public keys are not exchanged password will be asked twice'
# Copy .ros-root folder to pepper home folder
scp -r '.ros-root' nao@$hostname:'~'
# execute install script inside pepper
ssh nao@$hostname $copy_script
