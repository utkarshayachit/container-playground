#!/usr/bin/env bash
set -e +x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Build the containers
container_name=""
container_tag_suffix=""

# default options
DO_PUSH=0
DO_HELP=0
DO_HPCX=0
DO_MPICH=1
DO_PARAVIEW=1

# proces command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--push) DO_PUSH=1 ;;
        -h|--help) DO_HELP=1 ;;
        --hpcx) DO_HPCX=1 ;;
        --no-hpcx) DO_HPCX=0 ;;
        --mpich) DO_MPICH=1 ;;
        --no-mpich) DO_MPICH=0 ;;
        --paraview) DO_PARAVIEW=1 ;;
        --no-paraview) DO_PARAVIEW=0 ;;
        *)
            if [ -z "$container_name" ]; then
                container_name=$1
            elif [ -z "$container_tag_suffix" ]; then
                container_tag_suffix=$1
            fi
            ;;
    esac
    shift
done

if [ -z "$container_name" ] || [ "$DO_HELP" -eq 1 ]; then
    echo "Usage: $0 [OPTIONS] <container_name> [tag_suffix]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -p, --push      Push the container to the registry"
    echo "  --hpcx          Build the container with HPC-X"
    echo "  --no-hpcx       Do not build the container with HPC-X (default)"
    echo "  --mpich         Build the container with MPICH (default)"
    echo "  --no-mpich      Do not build the container with MPICH"
    echo "  --paraview      Build the container with ParaView (requires --mpich) (default)"
    echo "  --no-paraview   Do not build the container with ParaView"
    exit 1
fi

# validate command line options
if [ "$DO_MPICH" -eq 0 ] && [ "$DO_PARAVIEW" -eq 1 ]; then
    echo "ParaView requires MPICH, please use --mpich or --no-paraview"
    exit 1
fi


# all container images to built
all_container_images=()

# builds the base container with chosen MPI implementation(s)
function build_mpi_container() {
    local base=$1
    local mpi=$2
    local container_name=$3
    local container_tag_suffix=$4

    local tag=$container_name:$mpi$container_tag_suffix
    docker build . -f Dockerfile \
        -t $tag \
        --build-arg BASE=$base \
        --build-arg MPI=$mpi \

    all_container_images+=( $tag )
}

# builds the ParaView container
function build_paraview_container() {
    local base=$1
    local gl_variant=$2
    local container_name=$3
    local container_tag_suffix=$4

    local tag=$container_name:pv-$gl_variant$container_tag_suffix
    docker build . -f Dockerfile.paraview \
        -t $tag \
        --build-arg BASE=$base \
        --build-arg GL_VARIANT=$gl_variant

    all_container_images+=( $tag )
}

pushd $SCRIPT_DIR

mpi_impl=""
if [ "$DO_HPCX" -eq 1 ] && [ "$DO_MPICH" -eq 1 ]; then
    mpi_impl="mpich+hpcx"
elif [ "$DO_MPICH" -eq 1 ]; then
    mpi_impl="mpich"
elif [ "$DO_HPCX" -eq 1 ]; then
    mpi_impl="hpcx"
fi

build_mpi_container ubuntu:20.04 $mpi_impl "$container_name" "$container_tag_suffix"
build_mpi_container nvidia/opengl:1.2-glvnd-devel-ubuntu20.04 $mpi_impl "$container_name" "-glvnd$container_tag_suffix"

if [ "$DO_PARAVIEW" -eq 1 ]; then
    # Build the container for paraview-osmesa
    build_paraview_container $container_name:$mpi_impl$container_tag_suffix osmesa "$container_name" "$container_tag_suffix"

    # Build the container for paraview-egl
    build_paraview_container $container_name:$mpi_impl-glvnd$container_tag_suffix egl "$container_name" "$container_tag_suffix"
fi

if [ "$DO_PUSH" -eq 1 ]; then
    for tag in "${all_container_images[@]}"; do
        docker push $tag
    done
fi

popd
