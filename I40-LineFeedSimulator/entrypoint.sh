#!/usr/bin/env bash
# Container entrypoint (PID 1) for the LineFeed Simulator.
# Manages the simulator process lifecycle: starts it, restarts it when killed
# by lfs-restart, and shuts down cleanly when the container stops.
set -uo pipefail

ARGS_FILE="/run/lfs-args"
LOG_FILE="/logs/simulator.log"
DEFAULT_ARGS="--speed 5 --loop"
PYTHON_PID=""

# Write defaults on every fresh container start
echo "$DEFAULT_ARGS" > "$ARGS_FILE"

_shutdown() {
    echo "[lfs] Container stopping..."
    if [[ -n "$PYTHON_PID" ]]; then
        kill "$PYTHON_PID" 2>/dev/null || true
        wait "$PYTHON_PID" 2>/dev/null || true
    fi
    exit 0
}
trap _shutdown SIGTERM SIGINT

while true; do
    ARGS=$(cat "$ARGS_FILE")
    : > "$LOG_FILE"
    echo "[lfs] Starting: python main.py $ARGS"

    uv run python main.py $ARGS &
    PYTHON_PID=$!

    wait "$PYTHON_PID" || true
    PYTHON_PID=""

    echo "[lfs] Simulator process ended — restarting..."
done
