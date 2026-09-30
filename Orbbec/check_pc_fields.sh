#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash
unset CYCLONEDDS_URI
export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "=== Starting camera ==="
ros2 launch astra_camera astra.launch.xml depth_registration:=true enable_colored_point_cloud:=true > /tmp/astra_check.log 2>&1 &
PID=$!
sleep 5

echo "=== Topics ==="
ros2 topic list --no-daemon

echo -e "\n=== Fields of /camera/depth_registered/points ==="
timeout 4 ros2 topic echo /camera/depth_registered/points --no-arr --once || true

echo -e "\n=== Fields of /camera/depth/points ==="
timeout 4 ros2 topic echo /camera/depth/points --no-arr --once || true

kill -2 $PID 2>/dev/null
sleep 1
pkill -9 astra_camera_node 2>/dev/null || true
