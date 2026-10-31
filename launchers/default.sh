#!/bin/bash

source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

# ROS 2 runs over zenoh: attach this container to the robot's zenoh router as a *client*, so every
# message is routed by the robot (a peer session would try to link directly to the robot's nodes,
# which is impossible from a laptop or from inside docker). Works on the robot and from a laptop.
if [ -z "${ZENOH_CONFIG_OVERRIDE:-}" ] && [ -n "${VEHICLE_NAME:-}" ]; then
    export ZENOH_CONFIG_OVERRIDE="mode=\"client\";connect/endpoints=[\"tcp/${VEHICLE_NAME}.local:7447\"]"
fi

# launching app (ROS 2)
dt-exec ros2 launch ros2_basics drive_node.launch.py veh:="${VEHICLE_NAME}" car_cmd_topic:="${CAR_CMD_TOPIC:-car_cmd_switch_node/cmd}"

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE

# wait for app to end
dt-launchfile-join
