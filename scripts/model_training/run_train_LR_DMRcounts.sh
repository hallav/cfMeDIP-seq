#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --job-name=cfDNA_pipeline_train_LR_DMRcounts
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


THINNING=6 #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE1="$RESULTFOLDER"/DMRs/totalReadcount10_"$THINNING"/found_DMRS_allClasses_top_"$SLURM_ARRAY_TASK_ID".RData 
DMRFILE2="$RESULTFOLDER"/DMRs/totalReadcount10_"$THINNING"/found_DMRS_allClasses_bottom_"$SLURM_ARRAY_TASK_ID".RData 

OUTPUTFOLDER="$RESULTFOLDER"/LR_DMRcount/totalReadcount10_"$THINNING"

ID=$SLURM_ARRAY_TASK_ID

for CLASS in {1..8}
do
    srun Rscript --no-save train_LR_DMRcounts.R $ID $DMRFILE1 $DMRFILE2 $INPUTFILE "$OUTPUTFOLDER"/DMRcounts_allClasses_ID $CLASS $DATASPLITFILE
done
