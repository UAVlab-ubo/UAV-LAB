#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

echo "=== 1. Current Environment ==="
env | grep -E "ROS|RMW|CYCLONE"

echo -e "\n=== 2. Testing Discovery with rmw_cyclonedds_cpp ==="
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0
ros2 topic list --no-daemon
ros2 node list --no-daemon

echo -e "\n=== 3. Testing with FastDDS (rmw_fastrtps_cpp) ==="
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ros2 topic list --no-daemon
ros2 node list --no-daemon
