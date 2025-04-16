#!/bin/bash

#
#$ -cwd
#$ -j y
#$ -N theta
#$ -S /bin/bash
#$ -V
#$ -o log_output/output_$JOB_ID
#

#SBATCH -J theta
#SBATCH --cpus-per-task=1
#SBATCH --output=./log_output/%x.o%j
#SBATCH --error=./log_error/%x.e%j

# Positional arguments
if [[ $# -ge 4 ]]; then
  init_file="$1"
  steps="$2"
  shift 2
else
  echo "Error: init_file, steps required."
  exit 1
fi

# Optional arguments
lambda="0.0"
n="1"
threads="1"
nblocks="1"
seed="1"

# Read options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lambda)
      lambda="$2"
      shift 2
      ;;
    --n)
      n="$2"
      shift 2
      ;;
    --threads)
      threads="$2"
      shift 2
      ;;
    --nblocks)
      nblocks="$2"
      shift 2
      ;;
    --seed)
      seed="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done


julia --project=. -t $threads main.jl $init_file $steps --lambda $lambda -n $n --nblocks $nblocks --seed $seed -v