#!/bin/bash

#SBATCH -A c00859
#SBATCH --job-name=biobakery_workflows
#SBATCH --output=biobakery_%j.out
#SBATCH --error=biobakery_%j.err
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=10           # 10 separate tasks
#SBATCH --ntasks-per-node=10  # Adjust this based on your cluster's nodes capacity
#SBATCH --cpus-per-task=10    # Each task uses 10 cores
#SBATCH --mem-per-cpu=2G      # Adjust memory per CPU as needed

module load python
module load trimmomatic
module load sra-toolkit

# Check if input and output directories are provided
if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "ERROR: Input or output directory not specified."
  echo "Usage: sbatch run_biobakery.sh -v INPUT_DIR=<input_directory>,OUTPUT_DIR=<output_directory>"
  exit 1
fi

# Ensure each task runs the workflow command independently
for i in $(seq 1 ${SLURM_NTASKS}); do
  srun --exclusive --ntasks=1 --cpus-per-task=${SLURM_CPUS_PER_TASK} \
  biobakery_workflows wmgx \
    --input ${INPUT_DIR}/job_${i} \
    --output ${OUTPUT_DIR}/job_${i} \
    --input-extension fastq \
    --pair-identifier _1 \
    --remove-intermediate-output \
    --bypass-strain-profiling \
    --qc-options="--bypass-trf --remove-intermediate-output" \
    --local-jobs 1 \
    --threads ${SLURM_CPUS_PER_TASK} &
done
wait
