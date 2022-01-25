#!/bin/sh -l
#SBATCH --time=03:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_LR_RHS_newTransformation


#SBATCH --array=1-100


if (($#==1)); then

    #Updated the Perl and sqlite modules for R3.6.1
    module load Perl/5.28.0-GCCcore-7.3.0
    module load sqlite/3.28.0
    module load r/3.6.1-python3
  
    INPUTFILE=".../BrainData_6classes_datamatrix.RData"
    DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"

    ID=$SLURM_ARRAY_TASK_ID

    DMRFILE=".../results/DMRs/modifiedt_newTransformation/found_DMRS_allClasses_"$ID".RData"
    OUTPUTFOLDER=".../results/LR_RHS/LR_RHS_newTransformation"

    CLASS=$1

    P0=300

    #List of input arguments
    #1 Data split ID
    #2 Filename into which the FeatureList object has been stored, with whole path
    #3 Data file
    #4 Output folder and file name id
    #5 For which class the model is being trained (index)
    #6 Data splits file
    #7 Parameter p0
    #8 new (1) or old (0) transformation

    TRANSFORMATION=1

    srun Rscript --no-save train_LR_RHS_intracranial_tumors.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $TRANSFORMATION

else

    echo 'Wrong amount of arguments'

fi
