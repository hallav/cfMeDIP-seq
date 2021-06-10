#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=50G
#SBATCH --job-name=cfDNA_pipeline
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#To produce the other thinning versions, change total read count to 100000 and 1000000 (and file name extension correspondingly)

TOTAL_READ_COUNT=10000
FILE_NAME_ID="totalReadcount10_4"

srun Rscript --no-save thin_data_validation.R $TOTAL_READ_COUNT $FILE_NAME_ID

