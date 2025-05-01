#!/bin/bash

# List of missing key IDs
MISSING_KEYS=("54404762BBB6E853" "BDE6D2B9216EC7A8" "1140AF8F639E0C39" "0E98404D386FA1D9" "6ED0E7B82643E131" "F8D2585B8783D481")

# Key server to use
KEY_SERVER="keyserver.ubuntu.com"

# Loop through each missing key and add it
for KEY in "${MISSING_KEYS[@]}"; do
    echo "Adding key: $KEY"
    sudo apt-key adv --keyserver "$KEY_SERVER" --recv-keys "$KEY"
done

# Update package list
echo "Updating package list..."
sudo apt update

echo "Automation complete!"
