#!/bin/bash

rm -rf ./build/dist

mkdir ./build/dist

sudo podman build --network=host -t localhost/turtlinux:latest .

sudo podman run --rm -it --privileged \
  --network=host \
  -v ./build/dist:/output \
  -v ./config.toml:/config.toml:ro \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  --rootfs ext4 \
  localhost/turtlinux:latest