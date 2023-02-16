#!/usr/bin/env bash

# Expected environment variables:
#   OS_NAME=ubuntu
#   OS_VER=20.04
#   MOFED_VER=5.6-2.0.9.0
#   PLATFORM=x86_64
set -e -x

. ${BASH_SOURCE%/*}/install_packages.sh \
    ca-certificates \
    curl \
    environment-modules \
    gnupg2 \
    iproute2 \
    libnl-3-dev \
    libnl-route-3-dev \
    libnuma-dev \
    libpmix-dev \
    net-tools \
    numactl \
    pciutils \
    perl \
    python3 \
    python3-dev \
    python3-pip \
    tzdata \
    udev \
    wget
 
cd /tmp
OS_SHORTNAME="${OS_NAME}${OS_VER}"
curl -L https://content.mellanox.com/ofed/MLNX_OFED-${MOFED_VER}/MLNX_OFED_LINUX-${MOFED_VER}-${OS_SHORTNAME}-${PLATFORM}.tgz -o MLNX_OFED.tgz
tar -xzvf MLNX_OFED.tgz
MLNX_OFED_LINUX-${MOFED_VER}-${OS_SHORTNAME}-${PLATFORM}/mlnxofedinstall --user-space-only --without-fw-update --all --force
rm MLNX_OFED.tgz
rm -rf /tmp/MLNX_OFED_LINUX-${MOFED_VER}-${OS_SHORTNAME}-${PLATFORM}

## HPC tuning
echo '
*               hard    memlock         unlimited
*               soft    memlock         unlimited
*               hard    nofile          65535
*               soft    nofile          65535
*               hard    stack           unlimited
*               soft    stack           unlimited' >> /etc/security/limits.conf
