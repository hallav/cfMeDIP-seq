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

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/Fishers_exact_test/found_DMRS_allClasses_"$ID".RData

OUTPUTFOLDER="$RESULTFOLDER"/GLMNET/sameReadcount10_"$THINNING"_Fisher

#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3 Thinned data file
#4 Output folder and file name id
#5 Data splits file
#6 new (1) or old (0) transformation

TRANSFORMATION=0

srun Rscript --no-save glmnet_training.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/wholeData_allClasses_10_glmnet_ID $DATASPLITFILE $TRANSFORMATION

