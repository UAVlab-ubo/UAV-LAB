#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "=== Starting astra.launch.xml ==="
ros2 launch astra_camera astra.launch.xml > /tmp/astra_launch.log 2>&1 &
LAUNCH_PID=$!
sleep 5

echo -e "\n=== 1. Color Frequency (/camera/color/image_raw) ==="
timeout 6 ros2 topic hz /camera/color/image_raw || true

echo -e "\n=== 2. Depth Frequency (/camera/depth/image_raw) ==="
timeout 6 ros2 topic hz /camera/depth/image_raw || true

echo -e "\n=== 3. PointCloud Frequency (/camera/depth/points) ==="
timeout 6 ros2 topic hz /camera/depth/points || true

kill -2 $LAUNCH_PID 2>/dev/null
sleep 1
pkill -9 astra_camera_node 2>/dev/null || true
echo "Stream test complete."
