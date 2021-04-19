#!/bin/sh -l
#SBATCH --time=03:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=cfDNA_pipeline_collect_data
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3


srun Rscript --no-save make_data_matrix_discovery.R

