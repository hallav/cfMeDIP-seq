#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --job-name=cfDNA_pipeline_train_LR_DMRcounts
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100

cd /scratch/work/hallav1/cfDNA/scripts/wholeData

THINNING=6 #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE1="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/Fishers_exact_test/found_DMRS_allClasses_top_"$SLURM_ARRAY_TASK_ID".RData 
DMRFILE2="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/Fishers_exact_test/found_DMRS_allClasses_bottom_"$SLURM_ARRAY_TASK_ID".RData 

OUTPUTFOLDER="$RESULTFOLDER"/LR_DMRcount/sameReadcount10_"$THINNING"_Fisher

ID=$SLURM_ARRAY_TASK_ID

for CLASS in {1..8}
do
    srun Rscript --no-save train_LR_DMRcounts.R $ID $DMRFILE1 $DMRFILE2 $INPUTFILE "$OUTPUTFOLDER"/DMRcounts_allClasses_ID $CLASS $DATASPLITFILE
done