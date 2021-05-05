#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_make_PCA_and_ISPCA_plots
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi

srun Rscript --no-save plot_PCA_and_ISPCA_results.R
