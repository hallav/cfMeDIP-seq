#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=60G
#SBATCH --job-name=cfDNA_pipeline_train_glmnet_noThinning
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


cd /scratch/work/hallav1/cfDNA/scripts/wholeData


DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholeData.RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_noThinning.RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE="$RESULTFOLDER"/noThinning/DMRs/found_DMRS_allClasses_"$ID".RData

OUTPUTFOLDER="$RESULTFOLDER"/GLMNET/noThinning/glmnet

#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3 Thinned data file
#4 Output folder and file name id
#5 Data splits file
#6 new (1) or old (0) transformation

TRANSFORMATION=0

srun Rscript --no-save glmnet_training_noThinning.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/wholeData_allClasses_10_glmnet_ID $DATASPLITFILE $TRANSFORMATION

