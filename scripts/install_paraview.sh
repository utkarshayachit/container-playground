#! /usr/bin/env bash

set -x -e

url_prefix="https://www.paraview.org/files/v$(echo ${PARAVIEW_VERSION} | cut -d. -f1-2)"/ParaView-${PARAVIEW_VERSION}
impl=${GL_VARIANT:-"osmesa"}

curl -L ${url_prefix}-${impl}-MPI-Linux-Python3.9-x86_64.tar.gz -o paraview.tar.gz

mkdir -p /opt/paraview
tar -xzvf paraview.tar.gz --strip-components 1 -C /opt/paraview
rm paraview.tar.gz
