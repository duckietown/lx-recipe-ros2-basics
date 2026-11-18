# LX Recipe: ROS 2 Basics

This is the recipe for the [`lx-ros2-basics`](https://github.com/duckietown/lx-ros2-basics)
Learning Experience (Duckietown, `ente` distribution, ROS 2 Jazzy over `rmw_zenoh_cpp`).
It holds everything the learner never edits: the Docker images, the dependencies, the launcher,
the Duckiematrix map and the notebook helpers.

Learners do not clone this repository. The Duckietown Shell pulls it automatically because
`lx-ros2-basics/.dtproject` points at it:

    RECIPE_REPOSITORY=duckietown/lx-recipe-ros2-basics
    RECIPE_BRANCH=ente

The ROS 1 version of this LX lives in `lx-ros-basics` / `lx-recipe-ros-basics`.

## What is here

| Path | Purpose |
| --- | --- |
| `Dockerfile` | image behind `dts code build` / `dts code workbench`: the learner's `packages/` are built with `colcon` on top of `dt-ros2-commons` |
| `Dockerfile.vscode` | image behind `dts code editor`: the browser editor with ROS 2 Jazzy, `duckietown_msgs` and the notebook panels |
| `dependencies-apt.txt` | runtime APT packages of the workbench image (none) |
| `dependencies-apt.vscode.txt` | ROS 2 Jazzy, `rmw_zenoh_cpp` and `colcon` for the editor image |
| `dependencies-py3.txt` | Python packages shared by both images (`ipywidgets`, `ipympl`, `matplotlib` for the notebook panels) |
| `launchers/default.sh` | what runs when the workbench container starts: `ros2 launch ros2_basics drive_node.launch.py` |
| `packages/lx_ros2_tools` | helpers used by the notebooks and the nodes: `RosSession`, `ParamPanel`, `ActionButtons`, `ImageView`, `TopicPlot`, `LiveParams`, image conversion |
| `assets/vscode/` | editor settings, ROS 2 in every terminal, writable `colcon` output directories |
| `assets/duckiematrix/` | the `loop` map used by `dts code start_matrix` |
| `settings.yaml` | Duckiematrix map and vehicle used by `dts code start_matrix` |

## How the images talk to the robot

The Duckiebot runs ROS 2 on the default domain and discovery goes through a **zenoh router** on
the robot (`tcp/ROBOT.local:7447`). The launcher (started by `dts code workbench -R ROBOT`) and the
editor terminals export
`ZENOH_CONFIG_OVERRIDE='mode="client";connect/endpoints=["tcp/ROBOT.local:7447"]'` from `VEHICLE_NAME`,
and `RosSession("ROBOT")` does the same inside a notebook (client mode: a peer session from outside the
robot would try to link directly to the robot's containers and see nothing). Note that `dts code editor` has
no robot option: inside the editor `VEHICLE_NAME` is the container hostname, so a terminal is pointed at a
robot by exporting `ZENOH_CONFIG_OVERRIDE` by hand (the LX README and notebooks 03/04 explain this), and a
local router for robot-less work is started with `ZENOH_CONFIG_OVERRIDE= ros2 run rmw_zenoh_cpp rmw_zenohd`.

## Testing local recipe changes

Check this repository out next to the LX and run, from the LX directory:

    dts code editor --recipe ../lx-recipe-ros2-basics
    dts code build -R ROBOT --recipe ../lx-recipe-ros2-basics

Inside the editor, **Terminal > New Terminal** gives a shell with `ros2`, `colcon` and the
`duckietown_msgs` interfaces:

    ros2 interface show duckietown_msgs/msg/Twist2DStamped
    cd "$COLCON_WS"
    colcon build --base-paths /code/src/lx-ros2-basics/packages --packages-select ros2_basics
    source install/setup.bash
    ros2 pkg executables ros2_basics
