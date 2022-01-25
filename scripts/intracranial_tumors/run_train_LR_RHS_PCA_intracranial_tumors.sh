#!/bin/sh -l
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_PCA_DMR


#SBATCH --array=1-100


if (($#==1)); then

    #Updated the Perl and sqlite modules for R3.6.1
    module load Perl/5.28.0-GCCcore-7.3.0
    module load sqlite/3.28.0
    module load r/3.6.1-python3


    INPUTFILE=".../BrainData_6classes_datamatrix.RData"
    DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"

    ID=$SLURM_ARRAY_TASK_ID

    PCAFILE=".../results/DMRs/PCA/PCA_results_dataSplit_"$ID".RData"
    OUTPUTFOLDER=".../results/LR_RHS/LR_RHS_PCA"
    PLOTFOLDER=$OUTPUTFOLDER

    CLASS=$1

    P0=100
    N_COMPONENTS=130 

    #List of input arguments
    #1 Data split ID
    #2 Filename into which the PCA result object has been stored, with whole path
    #3  data file
    #4 Output folder and file name id
    #5 For which class the model is being trained (index)
    #6 Data splits file
    #7 Parameter p0
    #8 Number of components to be used
    #9 Folder where to store (debug) plots


    srun Rscript --no-save train_LR_RHS_PCA_intracranial_tumors.R $ID $PCAFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $N_COMPONENTS $PLOTFOLDER

else

    echo 'Wrong amount of arguments'

fi
