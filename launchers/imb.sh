#!/usr/bin/env bash
set -e +x

DO_HELP=0
mpis=()
benchmark=IMB_MPI1
benchmark_args="PingPong"

# proces command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) DO_HELP=1 ;;
        --mpich) mpis+=("mpich") ;;
        --hpcx) mpis+=("hpcx") ;;
        *)
            benchmark=$1
            shift
            benchmark_args="$@"
            break
            ;;
    esac
    shift
done

# if no MPIs are specified, use all of the ones available in the container
if  [ ${#mpis[@]} -eq 0 ]; then
    mpis=($(echo $MPI | tr "+" " "))
fi

# if no MPIs or benchmarks are specified, show usage
if [ -z "$benchmark" ] || [ ${#mpis[@]} -eq 0 ]; then
    DO_HELP=1
fi

if [ "$DO_HELP" -eq 1 ]; then
    echo "Usage: $0 [OPTIONS] [BENCHMARK] [BENCHMARK_ARGS]"
    echo ""
    echo "Run the Intel MPI Benchmark (IMB) with the specified MPI implementation."
    echo "If no MPI implementation is specified, the script will use the MPI"
    echo "implementation(s) specified in the MPI environment variable."
    echo ""
    echo "BENCHMARK: IMB_MPI1 (default)"
    echo "BENCHMARK_ARGS: PingPong (default)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  --mpich         Run the benchmark with MPICH"
    echo "  --hpcx          Run the benchmark with HPC-X"
    exit 1
fi

source /etc/profile.d/modules.sh
for mpi in "${mpis[@]}"; do
    module purge
    module load mpi/$mpi

    u_mpi=$(echo $mpi | tr "[:lower:]" "[:upper:]")
    imb_dir=${u_mpi}_IMB_DIR
    exe="${!imb_dir}/$benchmark"
    "$exe" $benchmark_args
done
