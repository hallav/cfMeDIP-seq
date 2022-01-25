#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=20G
#SBATCH --job-name=cfDNA_pipeline_data_splits





#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

#1: output file name and path
#2: seed number

OUTPUTFILE="/results/datasplits/dataSplits_braindata.RData"

#set the seed to: 10^4 -> 4, 10^5 -> 5 10^6 -> 6, noThinning -> 7, intracranial tumors data -> 8

srun Rscript --no-save data_splits_intracranial_tumors.R $OUTPUTFILE 8

