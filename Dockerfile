ARG BASE=nvidia/opengl:1.2-glvnd-devel-ubuntu20.04
FROM ${BASE}

ENV OS_NAME=ubuntu
ENV OS_VER=20.04
ENV MOFED_VER=5.6-2.0.9.0
ENV PLATFORM=x86_64

ENV HPCX_VER "2.11"
ENV CUDA_VER "11"
ENV MPICH_VER "4.1"

ARG MPI=mpich+hpcx

# copy scripts
COPY scripts/install_hpcx.sh \
    scripts/install_mofed.sh \
    scripts/install_mpich.sh \
    scripts/install_packages.sh \
    /opt/scripts/

# install prerequisites
# install mofed & mpi implementations
RUN /opt/scripts/install_mofed.sh
RUN /opt/scripts/install_hpcx.sh
RUN /opt/scripts/install_mpich.sh

WORKDIR /opt
# launchers use this variable to know which MPI implementations
# are available
ENV MPI=${MPI}

COPY launchers /opt/launchers
CMD [ "/opt/launchers/imb_pingpong.sh"]
