#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash
unset CYCLONEDDS_URI
export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "=== 1. Starting Orbbec Astra Driver ==="
ros2 launch astra_camera astra.launch.xml depth_registration:=true enable_colored_point_cloud:=true > /tmp/astra_rtab.log 2>&1 &
ASTRA_PID=$!
sleep 5

echo "=== 2. Starting RTAB-Map SLAM ==="
ros2 launch rtabmap_launch rtabmap.launch.py \
    frame_id:=camera_link \
    rgb_topic:=/camera/color/image_raw \
    depth_topic:=/camera/depth/image_raw \
    camera_info_topic:=/camera/color/camera_info \
    approx_sync:=true \
    visual_odometry:=true \
    rtabmap_viz:=false \
    rviz:=false \
    args:="-d --RGBD/NeighborLinkRefining true --Reg/Strategy 0 --Vis/MinInliers 10" > /tmp/rtabmap.log 2>&1 &
RTAB_PID=$!
sleep 8

echo -e "\n=== 3. RTAB-Map Topics ==="
ros2 topic list --no-daemon | grep -E "rtabmap|odom|camera"

echo -e "\n=== 4. RTAB-Map Log Sample ==="
tail -n 25 /tmp/rtabmap.log

kill -2 $RTAB_PID $ASTRA_PID 2>/dev/null || true
sleep 2
pkill -9 astra_camera_node rtabmap rgbd_odometry 2>/dev/null || true
echo "Test complete."
