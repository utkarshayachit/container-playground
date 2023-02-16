#! /usr/bin/env bash
set -x -e

is_enabled=$(echo $MPI | tr '+' '\n' | grep -c "^hpcx$" || [[ $? == 1 ]])
if [ $is_enabled -eq 0 ]; then
    echo "Skipping HPC-X installation"
    exit 0
fi

# HPC-X v2.11
INSTALL_PREFIX=/opt
HPCX_TARBALL=hpcx-v${HPCX_VER}-gcc-MLNX_OFED_LINUX-5-${OS_NAME}${OS_VER}-cuda${CUDA_VER}-gdrcopy2-nccl2.11-x86_64.tbz
HPCX_DOWNLOAD_URL=https://azhpcstor.blob.core.windows.net/azhpc-images-store/${HPCX_TARBALL}
HPCX_FOLDER=hpcx-v${HPCX_VER}-gcc-MLNX_OFED_LINUX-5-${OS_NAME}${OS_VER}-cuda${CUDA_VER}-gdrcopy2-nccl2.11-x86_64 

wget --retry-connrefused --tries=3 --waitretry=5 ${HPCX_DOWNLOAD_URL}
tar -xvf ${HPCX_TARBALL} -C ${INSTALL_PREFIX}

HPCX_PATH=${INSTALL_PREFIX}/${HPCX_FOLDER}

# HPC-X module
# Module Files
MODULE_FILES_DIRECTORY=/usr/share/modules/modulefiles/mpi
mkdir -p ${MODULE_FILES_DIRECTORY}

echo "#%Module 1.0
#  HPCx v${HPCX_VER}
conflict   mpi
module load ${HPCX_PATH}/modulefiles/hpcx" >> ${MODULE_FILES_DIRECTORY}/hpcx-v${HPCX_VER}

# Softlinks
ln -s ${MODULE_FILES_DIRECTORY}/hpcx-v${HPCX_VER} ${MODULE_FILES_DIRECTORY}/hpcx
