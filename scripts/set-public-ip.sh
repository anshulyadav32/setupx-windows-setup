#!/bin/bash

# Set PUBLIC_IP environment variable for Google Cloud instances
# This script creates a profile script to export PUBLIC_IP on login
# and immediately sets it in the current session

sudo bash -c 'echo "export PUBLIC_IP=\$(curl -fs -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip || curl -fs ifconfig.me)" > /etc/profile.d/publicip.sh && chmod +x /etc/profile.d/publicip.sh && export PUBLIC_IP=$(curl -fs -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip || curl -fs ifconfig.me) && echo "✅ PUBLIC_IP set to: $PUBLIC_IP"'
