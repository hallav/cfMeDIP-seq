#!/bin/sh -l
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=500M
#SBATCH --job-name=cfDNA_plot_AUC_medians
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi

srun Rscript --no-save plot_AUC_differences_discovery.sh
