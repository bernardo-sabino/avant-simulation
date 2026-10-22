#!/bin/bash

SESSION_NAME="ardupilot_gazebo"
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARDUPILOT_DIR="${ARDUPILOT_DIR:-$WORKSPACE_DIR/ardupilot}"
if [[ ! -d "$ARDUPILOT_DIR" && -d /opt/ardupilot ]]; then
	ARDUPILOT_DIR=/opt/ardupilot
fi

tmux kill-session -t $SESSION_NAME 2>/dev/null
pkill -TERM -x mavros_node 2>/dev/null || true
pkill -TERM -f "ros2 run mavros mavros_node" 2>/dev/null || true
sleep 1

# 1. Painel Esquerdo (0.0): ArduPilot SITL
tmux new-session -d -s $SESSION_NAME -n 'simulation'
tmux send-keys -t $SESSION_NAME:0.0 "cd $ARDUPILOT_DIR" C-m
tmux send-keys -t $SESSION_NAME:0.0 "Tools/autotest/sim_vehicle.py -v ArduCopter -f gazebo-iris -N" C-m

# 2. Painel Direito Superior (0.1): Gazebo
sleep 3
tmux split-window -h -t $SESSION_NAME:0
tmux send-keys -t $SESSION_NAME:0.1 "export QT_X11_NO_MITSHM=1" C-m
tmux send-keys -t $SESSION_NAME:0.1 "export XDG_RUNTIME_DIR=/tmp/runtime-\$USER && mkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR" C-m
tmux send-keys -t $SESSION_NAME:0.1 "export GAZEBO_MODEL_DATABASE_URI=file:///dev/null" C-m
tmux send-keys -t $SESSION_NAME:0.1 "source /opt/ros/humble/setup.bash 2>/dev/null || true" C-m
tmux send-keys -t $SESSION_NAME:0.1 "export GAZEBO_MODEL_PATH=$WORKSPACE_DIR/simulation/drone:$WORKSPACE_DIR/simulation/worlds:/opt/ardupilot_gazebo/models:/usr/share/gazebo-11/models" C-m
tmux send-keys -t $SESSION_NAME:0.1 "gazebo --verbose $WORKSPACE_DIR/simulation/worlds/grassworld/grassworld.world; exec bash" C-m

# 3. Painel Direito Inferior (0.2): MAVROS
sleep 2
tmux split-window -v -t $SESSION_NAME:0.1
tmux send-keys -t $SESSION_NAME:0.2 "source /opt/ros/humble/setup.bash 2>/dev/null || true" C-m
tmux send-keys -t $SESSION_NAME:0.2 "sleep 5" C-m
tmux send-keys -t $SESSION_NAME:0.2 "ros2 run mavros mavros_node --ros-args -p fcu_url:=udp://127.0.0.1:14550@14555 -p plugin_allowlist:=\"[sys_status, command, wp, global_position, local_position, setpoint_position, set_point_vel, safety_allowed]\"; exec bash" C-m

# Ajusta proporções e anexa
tmux resize-pane -t $SESSION_NAME:0.0 -x 50%
tmux select-layout -t $SESSION_NAME:0 main-vertical
tmux attach-session -t $SESSION_NAME