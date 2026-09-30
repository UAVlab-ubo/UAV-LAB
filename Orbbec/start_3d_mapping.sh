#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

unset CYCLONEDDS_URI
export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

echo "Limpiando procesos previos..."
pkill -9 -f astra_camera_node 2>/dev/null || true
pkill -9 -f foxglove_bridge 2>/dev/null || true
pkill -9 -f rtabmap 2>/dev/null || true
pkill -9 -f rgbd_odometry 2>/dev/null || true
sleep 1

echo "================================================================"
echo "    Iniciando Mapeo 3D (RTAB-Map SLAM) con Orbbec Astra"
echo "================================================================"

trap 'kill $(jobs -p) 2>/dev/null; pkill -9 -f rtabmap 2>/dev/null; pkill -9 -f rgbd_odometry 2>/dev/null; pkill -9 -f astra_camera_node 2>/dev/null; pkill -9 -f foxglove_bridge 2>/dev/null; exit 0' SIGINT SIGTERM EXIT

echo -e "\n[1/3] Lanzando Driver Orbbec Astra (RGB-D)..."
ros2 launch astra_camera astra.launch.xml depth_registration:=true enable_colored_point_cloud:=true &
sleep 4

echo -e "\n[2/3] Lanzando Foxglove Bridge (ws://localhost:8765)..."
ros2 launch foxglove_bridge foxglove_bridge_launch.xml &
sleep 2

echo -e "\n[3/3] Lanzando RTAB-Map 3D SLAM & Odometría Visual..."
ros2 launch rtabmap_launch rtabmap.launch.py \
    frame_id:=camera_link \
    rgb_topic:=/camera/color/image_raw \
    depth_topic:=/camera/depth/image_raw \
    camera_info_topic:=/camera/color/camera_info \
    approx_sync:=true \
    visual_odometry:=true \
    rtabmap_viz:=false \
    rviz:=false \
    args:="-d --RGBD/NeighborLinkRefining true --Reg/Strategy 0 --Vis/MinInliers 10"
