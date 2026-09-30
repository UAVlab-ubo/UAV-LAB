#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "=== Starting astra.launch.xml in background ==="
ros2 launch astra_camera astra.launch.xml > /tmp/astra_launch.log 2>&1 &
LAUNCH_PID=$!
echo "Launch PID: $LAUNCH_PID"

echo "Waiting 5 seconds for camera driver initialization..."
sleep 5

echo -e "\n=== Driver Log Output ==="
cat /tmp/astra_launch.log

echo -e "\n=== Active Nodes ==="
ros2 node list --no-daemon

echo -e "\n=== Active Topics ==="
ros2 topic list --no-daemon

echo -e "\n=== Checking Frequency of Color Topic (5 seconds) ==="
timeout 5 ros2 topic hz /camera/color/image_raw --no-daemon || true

echo -e "\n=== Checking Frequency of Depth Topic (5 seconds) ==="
timeout 5 ros2 topic hz /camera/depth/image_raw --no-daemon || true

echo -e "\n=== Checking Frequency of PointCloud Topic (5 seconds) ==="
timeout 5 ros2 topic hz /camera/depth_registered/points --no-daemon || true

echo -e "\n=== Stopping Launch Process ==="
kill -2 $LAUNCH_PID 2>/dev/null
sleep 2
kill -9 $LAUNCH_PID 2>/dev/null || true
pkill -9 astra_camera_node 2>/dev/null || true
echo "Test finished."
