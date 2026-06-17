#!/bin/bash
sudo setenforce 0

mkdir -p build

# Configure your Kickstart file here
kickstart_file="turtlinux-test.ks"

ksflatten -c ./${kickstart_file} -o ./build/flat-${kickstart_file}

cd build

rm -rf ./iso_out

sudo livemedia-creator \
    --make-iso \
    --ks=./flat-${kickstart_file} \
    --no-virt \
    --resultdir=./iso_out \
    --project=TurtLinux \
    --releasever=44 \
    --iso-only \
    --iso-name=turtlinux-live.iso

sudo setenforce 1