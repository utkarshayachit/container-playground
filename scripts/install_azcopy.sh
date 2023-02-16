#!/usr/bin/env bash

## install azcopy
set -x -e

cd /usr/bin
wget -q https://aka.ms/downloadazcopy-v10-linux -O - | tar zxf - --strip-components 1 --wildcards '*/azcopy'
chmod 755 /usr/bin/azcopy
