#!/bin/bash
python3 - << 'EOF'
with open('/home/matias/.bashrc', 'r') as f:
    lines = f.readlines()

clean_lines = lines[:119]

ros_block = """
# opencode
export PATH=/home/matias/.opencode/bin:$PATH
export PATH=$PATH:/opt/xtensa-esp-elf/bin/

# ROS 2 Jazzy & Workspace Setup
source /opt/ros/jazzy/setup.bash
source /home/matias/ros2_ws/install/setup.bash

# DDS and Discovery Configuration for WSL2
unset CYCLONEDDS_URI
export ROS_DOMAIN_ID=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export ROS_STATIC_PEERS="127.0.0.1"
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_CLI_USE_DAEMON=0

# ROS 2 CLI shortcuts (bypassing daemon bug ros2cli#934)
alias rtl='ros2 topic list --no-daemon'
alias rnl='ros2 node list --no-daemon'
alias rti='ros2 topic info --no-daemon'
alias rth='ros2 topic hz'
alias rni='ros2 node info --no-daemon'
"""

with open('/home/matias/.bashrc', 'w') as f:
    f.writelines(clean_lines)
    f.write(ros_block)
print("Updated ~/.bashrc with unset CYCLONEDDS_URI")
EOF
