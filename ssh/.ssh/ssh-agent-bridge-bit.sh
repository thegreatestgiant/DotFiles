export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

#!/bin/bash

# Only run this if we are in a WSL environment
if grep -q "microsoft" /proc/version 2>/dev/null; then
    export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

    # Check if the socket is already being listened to
    if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
        rm -f "$SSH_AUTH_SOCK"

        # Start the bridge in the background
        # We use the symlink 'npiperelay.exe' you created earlier
        (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi
fi
