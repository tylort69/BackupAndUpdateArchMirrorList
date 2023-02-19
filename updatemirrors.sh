#!/bin/bash
dateandtime=$(date +%F-%H-%M-%S)
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist${dateandtime}.bak
echo "Mirror file backup created: /etc/pacman.d/mirrorlist${dateandtime}.bak"
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo "Mirror list update complete."
