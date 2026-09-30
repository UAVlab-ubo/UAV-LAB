#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0
export CYCLONE_INCLUDE_INTERFACE_NAMES="lo"

echo "=== Testing Discovery with PID 1055 exact env ==="
ros2 topic list --no-daemon
ros2 node list --no-daemon
