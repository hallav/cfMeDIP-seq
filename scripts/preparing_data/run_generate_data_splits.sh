#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=20G
#SBATCH --job-name=cfDNA_pipeline_data_splits
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#1: thinned whole data file name and path
#2: output file name and path
#3: seed number
#4: non-thinned whole data file name and path

THINNING=6
DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
OUTPUTFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData
WHOLEDATAFILE="$DATAFOLDER"/wholeData.RData

#set the seed to: 10^4 -> 4, 10^5 -> 5 10^6 -> 6

srun Rscript --no-save generate_data_splits.R $INPUTFILE $OUTPUTFILE 6

