#!/usr/bin/env bash
set -x -e

source /etc/profile.d/modules.sh
module load mpi/hpcx
"$@"
