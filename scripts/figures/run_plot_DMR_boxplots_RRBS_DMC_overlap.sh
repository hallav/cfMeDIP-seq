#!/bin/sh -l
#SBATCH --time=05:00:00
#SBATCH --mem-per-cpu=500M
#SBATCH --job-name=cfDNA_plot_validation_ROCs
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi

srun Rscript --no-save plot_DMR_boxplots_RRBS_DMC_overlap.R
