#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "=== Launching with depth_registration:=true enable_colored_point_cloud:=true ==="
ros2 launch astra_camera astra.launch.xml depth_registration:=true enable_colored_point_cloud:=true > /tmp/astra_pc.log 2>&1 &
LAUNCH_PID=$!
sleep 5

echo "=== Topics Published ==="
ros2 topic list --no-daemon

echo -e "\n=== Checking Color Point Cloud (/camera/depth_registered/points) ==="
timeout 6 ros2 topic hz /camera/depth_registered/points || true

echo -e "\n=== Checking Depth Point Cloud (/camera/depth/points) ==="
timeout 6 ros2 topic hz /camera/depth/points || true

kill -2 $LAUNCH_PID 2>/dev/null
sleep 1
pkill -9 astra_camera_node 2>/dev/null || true
