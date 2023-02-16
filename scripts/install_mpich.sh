#!/usr/bin/env bash
set -x -e

is_enabled=$(echo $MPI | tr '+' '\n' | grep -c "^mpich$" || [[ $? == 1 ]])
if [ $is_enabled -eq 0 ]; then
    echo "Skipping MPICH installation"
    exit 0
fi

INSTALL_PREFIX=/opt
MPICH_TARBALL=mpich-${MPICH_VER}.tar.gz
MPICH_DOWNLOAD_URL=https://www.mpich.org/static/downloads/${MPICH_VER}/${MPICH_TARBALL}
MPICH_FOLDER=mpich-${MPICH_VER}

wget --retry-connrefused --tries=3 --waitretry=5 ${MPICH_DOWNLOAD_URL}
tar -xvf ${MPICH_TARBALL} -C /tmp/
rm -rf ${MPICH_TARBALL}

cd /tmp/${MPICH_FOLDER}
./configure --prefix=${INSTALL_PREFIX}/${MPICH_FOLDER} \
    --with-pm=no \
    --with-device=ch4:ucx  \
    --with-pmi=pmix \
    --with-pmix=/usr/lib/x86_64-linux-gnu/pmix
make -j $(nproc)
make install
rm -rf /tmp/${MPICH_FOLDER}

#-----------------------------------------------------------------------------------------------------------------------
# install osu benchmarks
mkdir -p /tmp/osu_benchmarks
cd /tmp/osu_benchmarks

wget --retry-connrefused --tries=3 --waitretry=5 https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.0.1.tar.gz
tar -xvf osu-micro-benchmarks-7.0.1.tar.gz --strip-components 1
rm -rf osu-micro-benchmarks-7.0.1.tar.gz

./configure CC=${INSTALL_PREFIX}/mpich-${MPICH_VER}/bin/mpicc CXX=${INSTALL_PREFIX}/mpich-${MPICH_VER}/bin/mpicxx \
    --prefix=${INSTALL_PREFIX}/mpich-${MPICH_VER}/osu_benchmarks
make -j $(nproc)
make install
rm -rf /tmp/osu_benchmarks

#-----------------------------------------------------------------------------------------------------------------------
# install intel MPI benchmarks
mkdir -p ${INSTALL_PREFIX}/mpich-${MPICH_VER}/imb
cd ${INSTALL_PREFIX}/mpich-${MPICH_VER}/imb
wget https://github.com/intel/mpi-benchmarks/archive/refs/tags/IMB-v2021.3.tar.gz
tar -xvf IMB-v2021.3.tar.gz --strip-components 1
rm -rf IMB-v2021.3.tar.gz

CC=${INSTALL_PREFIX}/mpich-${MPICH_VER}/bin/mpicc CXX=${INSTALL_PREFIX}/mpich-${MPICH_VER}/bin/mpicxx \
    make -j $(nproc)

#-----------------------------------------------------------------------------------------------------------------------
# setup module file
MODULE_FILES_DIRECTORY=/usr/share/modules/modulefiles/mpi
mkdir -p ${MODULE_FILES_DIRECTORY}

echo "#%Module 1.0
# MPICH v${MPICH_VER}
conflict   mpi

module-whatis   \"Loads MPICH ${MPICH_VER}\"

set root   ${INSTALL_PREFIX}/mpich-${MPICH_VER}

setenv MPICH_ROOT       \$root
setenv MPICH_OSU_DIR    \$root/osu_benchmarks
setenv MPICH_IMB_DIR    \$root/imb

prepend-path PATH               \$root/bin
prepend-path LD_LIBRARY_PATH    \$root/lib" >> ${MODULE_FILES_DIRECTORY}/mpich-v${MPICH_VER}

# Softlinks
ln -s ${MODULE_FILES_DIRECTORY}/mpich-v${MPICH_VER} ${MODULE_FILES_DIRECTORY}/mpich
