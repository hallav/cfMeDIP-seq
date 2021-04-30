#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=15G
#SBATCH --job-name=cfDNA_pipeline_train_LR_DMRcounts_noThinning
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholeData.RData
DATASPLITFILE="$RESULTFOLDER"/dataSplits_noThinning.RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE1="$RESULTFOLDER"/DMRs/noThinning/DMRs/found_DMRS_allClasses_top_"$SLURM_ARRAY_TASK_ID".RData
DMRFILE2="$RESULTFOLDER"/DMRs/noThinning/DMRs/found_DMRS_allClasses_bottom_"$SLURM_ARRAY_TASK_ID".RData 

OUTPUTFOLDER="$RESULTFOLDER"/LR_DMRcount/noThinning/LR_DMRcount

ID=$SLURM_ARRAY_TASK_ID

for CLASS in {1..8}
do
    srun Rscript --no-save train_LR_DMRcounts_noThinning.R $ID $DMRFILE1 $DMRFILE2 $INPUTFILE "$OUTPUTFOLDER"/DMRcounts_allClasses_ID $CLASS $DATASPLITFILE
done
