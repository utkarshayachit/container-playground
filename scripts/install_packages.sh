set -e -x

export DEBIAN_FRONTEND=noninteractive
export TZ=America/New_York

# install some basic packages
apt-get update
apt-get -o apt::install-recommends=false install -y "$@"

apt-get clean -y
rm -rf /var/lib/apt/lists/*
