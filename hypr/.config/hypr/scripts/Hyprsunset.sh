#!/usr/bin/env bash
set -euo pipefail

# Hyprsunset with Automatic Scheduling
# Automatically enables night light after sunset, disables at sunrise
#
# Customize via env vars or edit directly:
#   HYPRSUNSET_TEMP        default 4500 (K)
#   HYPRSUNSET_START_TIME  default 19:00 (7 PM)
#   HYPRSUNSET_END_TIME    default 07:00 (7 AM)
#   HYPRSUNSET_ICON_MODE   sunset|blue (default: sunset)

STATE_FILE="$HOME/.cache/.hyprsunset_state"
SCHEDULE_FILE="$HOME/.config/hypr/.hyprsunset_schedule"
TARGET_TEMP="${HYPRSUNSET_TEMP:-4500}"
ICON_MODE="${HYPRSUNSET_ICON_MODE:-sunset}"

# Default schedule (24-hour format)
START_TIME="${HYPRSUNSET_START_TIME:-19:00}" # Enable at 7 PM
END_TIME="${HYPRSUNSET_END_TIME:-07:00}"     # Disable at 7 AM

ensure_state() {
    [[ -f "$STATE_FILE" ]] || echo "off" >"$STATE_FILE"
}

# Load custom schedule if exists
load_schedule() {
    if [[ -f "$SCHEDULE_FILE" ]]; then
        source "$SCHEDULE_FILE"
    fi
}

# Icons
icon_off() {
    printf "☀"
}

icon_on() {
    case "$ICON_MODE" in
    sunset) printf "🌇" ;;
    blue) printf "☀" ;;
    *) printf "☀" ;;
    esac
}

# Check if current time is within night light hours
should_be_active() {
    local current_time=$(date +%H:%M)
    local current_mins=$(date +%H:%M | awk -F: '{print ($1 * 60) + $2}')
    local start_mins=$(echo "$START_TIME" | awk -F: '{print ($1 * 60) + $2}')
    local end_mins=$(echo "$END_TIME" | awk -F: '{print ($1 * 60) + $2}')

    # Handle overnight period (e.g., 19:00 to 07:00)
    if [[ $start_mins -gt $end_mins ]]; then
        if [[ $current_mins -ge $start_mins ]] || [[ $current_mins -lt $end_mins ]]; then
            return 0 # Should be active
        fi
    else
        # Same-day period (e.g., 09:00 to 17:00)
        if [[ $current_mins -ge $start_mins ]] && [[ $current_mins -lt $end_mins ]]; then
            return 0 # Should be active
        fi
    fi

    return 1 # Should be inactive
}

# Start hyprsunset
start_hyprsunset() {
    if pgrep -x hyprsunset >/dev/null 2>&1; then
        return 0 # Already running
    fi

    if command -v hyprsunset >/dev/null 2>&1; then
        nohup hyprsunset -t "$TARGET_TEMP" >/dev/null 2>&1 &
        echo "on" >"$STATE_FILE"
        notify-send -u low "Hyprsunset: Auto-enabled" "${TARGET_TEMP}K (${START_TIME}-${END_TIME})" || true
    fi
}

# Stop hyprsunset
stop_hyprsunset() {
    if ! pgrep -x hyprsunset >/dev/null 2>&1; then
        echo "off" >"$STATE_FILE"
        return 0 # Already stopped
    fi

    pkill -x hyprsunset || true
    sleep 0.2

    if command -v hyprsunset >/dev/null 2>&1; then
        nohup hyprsunset -i >/dev/null 2>&1 &
        sleep 0.3 && pkill -x hyprsunset || true
    fi

    echo "off" >"$STATE_FILE"
    notify-send -u low "Hyprsunset: Auto-disabled" "Next activation: ${START_TIME}" || true
}

# Manual toggle (for override)
cmd_toggle() {
    ensure_state
    state="$(cat "$STATE_FILE" || echo off)"

    if [[ "$state" == "on" ]]; then
        stop_hyprsunset
    else
        start_hyprsunset
    fi
}

# Automatic check (run by daemon/timer)
cmd_auto() {
    ensure_state
    load_schedule

    if should_be_active; then
        start_hyprsunset
    else
        stop_hyprsunset
    fi
}

# Status for Waybar
cmd_status() {
    ensure_state
    load_schedule

    if pgrep -x hyprsunset >/dev/null 2>&1; then
        onoff="on"
    else
        onoff="$(cat "$STATE_FILE" || echo off)"
    fi

    if [[ "$onoff" == "on" ]]; then
        txt="<span size='18pt'>$(icon_on)</span>"
        cls="on"
        tip="Night light on @ ${TARGET_TEMP}K\nSchedule: ${START_TIME}-${END_TIME}"
    else
        txt="<span size='16pt'>$(icon_off)</span>"
        cls="off"
        tip="Night light off\nNext: ${START_TIME}"
    fi
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$txt" "$cls" "$tip"
}

# Initialize on startup
cmd_init() {
    ensure_state
    load_schedule
    cmd_auto # Check schedule immediately
}

# Daemon mode (runs in background, checks every 30 min)
cmd_daemon() {
    echo "Starting Hyprsunset scheduler daemon..."
    while true; do
        cmd_auto
        sleep 1800 # 30 minutes
    done
}

# Configure schedule
cmd_config() {
    echo "Current schedule:"
    echo "  Start: $START_TIME"
    echo "  End: $END_TIME"
    echo "  Temperature: ${TARGET_TEMP}K"
    echo ""
    echo "To customize, edit: $SCHEDULE_FILE"
    echo "Example contents:"
    echo "  START_TIME='20:30'"
    echo "  END_TIME='06:00'"
    echo "  TARGET_TEMP='3500'"
}

case "${1:-}" in
toggle) cmd_toggle ;;
status) cmd_status ;;
init) cmd_init ;;
auto) cmd_auto ;;
daemon) cmd_daemon ;;
config) cmd_config ;;
*)
    echo "Hyprsunset Scheduler"
    echo "Usage: $0 [toggle|status|init|auto|daemon|config]"
    echo ""
    echo "Commands:"
    echo "  toggle  - Manual override (turn on/off)"
    echo "  status  - Show status (for Waybar)"
    echo "  init    - Initialize on startup"
    echo "  auto    - Check schedule and apply"
    echo "  daemon  - Run as background daemon"
    echo "  config  - Show configuration"
    exit 2
    ;;
esac
