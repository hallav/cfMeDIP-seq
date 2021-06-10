#!/bin/sh -l
#SBATCH --time=03:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=cfDNA_pipeline_collect_data
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


srun Rscript --no-save make_data_matrix_discovery.R

