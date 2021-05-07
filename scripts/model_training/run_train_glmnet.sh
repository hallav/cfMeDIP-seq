#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=cfDNA_pipeline_train_glmnet
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


THINNING=6 #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE="$RESULTFOLDER"/DMRs/totalReadcount10_"$THINNING"/found_DMRS_allClasses_"$ID".RData

OUTPUTFOLDER="$RESULTFOLDER"/GLMNET/totalReadcount10_"$THINNING"

TRANSFORMATION=0 #use the original data transformation

srun Rscript --no-save glmnet_training.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/wholeData_allClasses_10_glmnet_ID $DATASPLITFILE $TRANSFORMATION

