#!/bin/sh -l
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=500M
#SBATCH --job-name=cfDNA_plot_validation_ROCs




#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

srun Rscript --no-save make_plots_intracranial_tumors.R
srun Rscript --no-save make_tables_intracranial_tumors.R 


