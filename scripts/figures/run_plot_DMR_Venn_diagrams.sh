#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=1G
#SBATCH --job-name=DMR_comparison
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi

srun Rscript --no-save plot_DMR_Venn_diagrams.R
srun Rscript --no-save plot_DMR_Venn_diagrams_threshold.R
