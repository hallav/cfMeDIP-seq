#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_train_glmnet_braindata


#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3


INPUTFILE=".../BrainData_6classes_datamatrix.RData"
DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"

ID=$SLURM_ARRAY_TASK_ID
DMRFILE=".../results/DMRs/DMRs_Fisher/found_DMRS_allClasses_"$ID".RData"

OUTPUTFOLDER=".../results/GLMNET/glmnet_Fisher"

#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3  data file
#4 Output folder and file name id
#5 Data splits file
#6 new (1) or old (0) transformation

TRANSFORMATION=0

srun Rscript --no-save glmnet_training_intracranial_tumors.R  $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/wholeData_allClasses_10_glmnet_ID $DATASPLITFILE $TRANSFORMATION

