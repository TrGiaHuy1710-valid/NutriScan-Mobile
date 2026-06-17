#!/bin/bash

SESSION_NAME="nutrition-api"

# Check if session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? -eq 0 ]; then
  echo "Tmux session '$SESSION_NAME' already exists. Attach using:"
  echo "  tmux attach -t $SESSION_NAME"
  exit 0
fi

echo "Creating new tmux session: $SESSION_NAME..."
# Start a detached session
tmux new-session -d -s $SESSION_NAME -n "App"

# Pane 1: Run FastAPI Server
tmux send-keys -t $SESSION_NAME:0 "python run.py" C-m

# Split the window horizontally for Ngrok
tmux split-window -h -t $SESSION_NAME:0

# Pane 2: Run Ngrok Setup
tmux send-keys -t $SESSION_NAME:0.1 "./start_ngrok.sh" C-m

# Equalize pane sizes
tmux select-layout -t $SESSION_NAME:0 even-horizontal

echo "=================================================="
echo "Tmux session '$SESSION_NAME' successfully launched!"
echo "To monitor or attach to the processes, run:"
echo "  tmux attach -t $SESSION_NAME"
echo "=================================================="
