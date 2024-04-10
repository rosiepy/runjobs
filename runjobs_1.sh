#!/bin/bash

#SBATCH -A c00859
#SBATCH --job-name=biobakery_workflows
#SBATCH --output=biobakery_%j.out
#SBATCH --error=biobakery_%j.err
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=10           # Total tasks for the job
#SBATCH --ntasks-per-node=10  # Adjust this based on your cluster's nodes capacity
#SBATCH --cpus-per-task=10    # Each task uses 10 cores
#SBATCH --mem-per-cpu=2G      # Adjust memory per CPU as needed

module load python
module load trimmomatic
module load sra-toolkit

# Check if input and output directories are provided
if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "ERROR: Input or output directory not specified."
  echo "Usage: sbatch --export=INPUT_DIR=<input_directory>,OUTPUT_DIR=<output_directory> run_biobakery.sh"
  exit 1
fi

# Assuming biobakery_workflows handles parallel processing internally:
biobakery_workflows wmgx \
  --input ${INPUT_DIR} \
  --output ${OUTPUT_DIR} \
  --input-extension fastq \
  --pair-identifier _1 \
  --remove-intermediate-output \
  --bypass-strain-profiling \
  --qc-options="--bypass-trf --remove-intermediate-output" \
  --local-jobs 10 \
  --threads ${SLURM_CPUS_PER_TASK}
