#!/bin/sh -l
#SBATCH --time=03:00:00
#SBATCH --mem-per-cpu=70G
#SBATCH --job-name=cfDNA_pipeline
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi

#change total read count to 100000 and 1000000 (and file name extension correspondingly)

TOTAL_READ_COUNT=10000
FILE_NAME_ID="totalReadcount10_4"

srun Rscript --no-save thin_data_discovery.R $TOTAL_READ_COUNT $FILE_NAME_ID

