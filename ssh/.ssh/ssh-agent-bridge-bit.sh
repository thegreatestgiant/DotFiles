# Define your preferred sockets
WSL_SOCK="$HOME/.ssh/agent.sock"
LINUX_SOCK="/home/sean/.bitwarden-ssh-agent.sock"

# Function to detect WSL
is_wsl() {
    grep -q "microsoft" /proc/version 2>/dev/null
}

# 1. Check if we are currently accessed via SSH (Remote Forwarding)
# If we are remote, we usually want to keep the forwarded socket and do nothing.
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
    # Optional: Echo for debugging, remove later
    # echo "SSH session detected. Keeping existing socket forwarding."
    : # Do nothing
else
    # 2. We are local. Determine if WSL or Native Linux.
    if is_wsl; then
        # --- WSL LOGIC ---
        export SSH_AUTH_SOCK="$WSL_SOCK"
        if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
            rm -f "$SSH_AUTH_SOCK"
            (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
        fi
    else
        # --- NATIVE LINUX LOGIC ---
        # Force the switch to Bitwarden, overriding gnome-keyring
        export SSH_AUTH_SOCK="$LINUX_SOCK"
    fi
fi
