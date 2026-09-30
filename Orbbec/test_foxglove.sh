#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash
unset CYCLONEDDS_URI
export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "=== Starting foxglove_bridge ==="
ros2 launch foxglove_bridge foxglove_bridge_launch.xml > /tmp/foxglove_test.log 2>&1 &
PID=$!
sleep 4

echo "=== Bridge Log ==="
cat /tmp/foxglove_test.log

kill -2 $PID 2>/dev/null || true
pkill -9 foxglove_bridge 2>/dev/null || true
echo "Foxglove Bridge test finished."
