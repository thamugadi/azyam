#!/bin/sh
set -e
sudo losetup -f --offset 32768 DISK.APM #after 64 sectors
LOOP=$(sudo losetup -j DISK.APM | grep -o '/dev/loop[0-9]*' | tail -n1)
sudo mkfs.hfsplus $LOOP
sudo mount -o loop $LOOP ./mnt/
sudo chmod -R 777 ./mnt
