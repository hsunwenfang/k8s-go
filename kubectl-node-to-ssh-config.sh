#!/bin/bash

# Set the standard username and identity file for SSH
SSH_USER="azureuser"
IDENTITY_FILE="/home/hsunwen/.ssh/keys/hsunprivatecniaks-masternode.pem"

# Get node names and IPs from kubectl
 kubectl --kubeconfig /home/hsunwen/.kube/config get no -owide | tail -n +2 | awk '{print $1, $6}' | while read -r name ip; do
    # Generate SSH config entries
    echo "Host $name"
    echo "    HostName $ip"
    echo "    User $SSH_USER"
    echo "    IdentityFile $IDENTITY_FILE"
    echo ""
done > /home/hsunwen/.ssh/aksconfig

# Move the generated config to ~/.ssh/config (optional)
# mv ssh_config ~/.ssh/config