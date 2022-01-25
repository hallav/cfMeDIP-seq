#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=cfDNA_pipeline_train_glmnet
#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

#Change THINNING and FEATUREN to go through all DMR numbers and thinning versions
THINNING=6
FEATUREN=200

INPUTFILE=.../results/thinneddata/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
DATASPLITFILE=.../results/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE=".../results/DMRs/sameReadcount10_"$THINNING"/newTransformation/featureN"$FEATUREN"/found_DMRS_allClasses_"$ID".RData"

OUTPUTFOLDER=.../results/GLMNET/featureN/N"$FEATUREN"/sameReadcount10_"$THINNING"_newTransformation

#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3 Thinned data file
#4 Output folder and file name id
#5 Data splits file
#6 new (1) or old (0) transformation

TRANSFORMATION=1

srun Rscript --no-save glmnet_training.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/wholeData_allClasses_10_glmnet_ID $DATASPLITFILE $TRANSFORMATION

