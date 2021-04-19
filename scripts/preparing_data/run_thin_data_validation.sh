#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=50G
#SBATCH --job-name=cfDNA_pipeline
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

#To produce the other thinning versions, change total read count to 100000 and 1000000 (and file name extension correspondingly)

TOTAL_READ_COUNT=10000
FILE_NAME_ID="sameReadcount10_4"

srun Rscript --no-save thin_data_validation.R $TOTAL_READ_COUNT $FILE_NAME_ID
