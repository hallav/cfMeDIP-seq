#!/bin/sh -l
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_braindata


#SBATCH --array=1-100


if (($#==1)); then

    #Updated the Perl and sqlite modules for R3.6.1
    module load Perl/5.28.0-GCCcore-7.3.0
    module load sqlite/3.28.0
    module load r/3.6.1-python3

    INPUTFILE=".../BrainData_6classes_datamatrix.RData"
    DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"

    ID=$SLURM_ARRAY_TASK_ID

    DMRFILE=".../results/DMRs/DMRs_Fisher/found_DMRS_allClasses_"$ID".RData"
    OUTPUTFOLDER=".../results/LR_RHS/LR_RHS_Fisher"

    CLASS=$1

    P0=300

    srun Rscript --no-save train_LR_Fisher_intracranial_tumors.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0

else

    echo 'Wrong amount of arguments'

fi
