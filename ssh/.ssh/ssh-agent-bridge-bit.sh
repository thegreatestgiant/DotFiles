# Only set a custom socket if one doesn't already exist!
if [ -z "$SSH_AUTH_SOCK" ]; then
    if grep -q "microsoft" /proc/version 2>/dev/null; then
        export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
        # ... (rest of your npiperelay logic)
        if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
            rm -f "$SSH_AUTH_SOCK"
            (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
        fi
    else
        # Only use this if we aren't forwarded and aren't in WSL
        export SSH_AUTH_SOCK=/home/sean/.bitwarden-ssh-agent.sock
    fi
fi
