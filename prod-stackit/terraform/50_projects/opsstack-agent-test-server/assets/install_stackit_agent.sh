#!/bin/bash

#Download GPG public key
curl https://stackit-server-agent.object.storage.eu01.onstackit.cloud/stackit-server-agent.gpg -o /tmp/stackit-server-agent.gpg

# Install dependencies

apt-get update && apt-get install gnupg -y

# Import GPG Public key
gpg --import /tmp/stackit-server-agent.gpg

# Download STACKIT Server Agent
curl https://stackit-server-agent.object.storage.eu01.onstackit.cloud/stackit-server-agent.deb -o /tmp/stackit-server-agent.deb

# Download the package signature file
curl https://stackit-server-agent.object.storage.eu01.onstackit.cloud/stackit-server-agent.deb.sig -o /tmp/stackit-server-agent.deb.sig

if gpg --verify /tmp/stackit-server-agent.deb.sig /tmp/stackit-server-agent.deb
then
    echo "The STACKIT Server Agent is verified successfully"
else
    echo "The STACKIT Server Agent is not verified successfully"
    rm -rf /tmp/stackit-server-agent.deb /tmp/stackit-server-agent.deb.sig /tmp/stackit-server-agent.gpg
    exit 1
fi

dpkg -i /tmp/stackit-server-agent.deb
rm -rf /tmp/stackit-server-agent.gpg /tmp/stackit-server-agent.deb.sig /tmp/stackit-server-agent.deb