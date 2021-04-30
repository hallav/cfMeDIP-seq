#!/bin/sh -l
#SBATCH --time=03:00:00
#SBATCH --mem-per-cpu=30G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_LR_RHS_newTransformation
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100

#When running this script one must give one input parameter: the class number (1-8) for which the classifyer is trained

if (($#==1)); then

    DATAFOLDER=...
    RESULTFOLDER=...

    INPUTFILE="$DATAFOLDER"/wholeData.RData
    DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_noThinning.RData

    ID=$SLURM_ARRAY_TASK_ID

    DMRFILE="$RESULTFOLDER"/DMRs/noThinning/DMRs_newTransformation/found_DMRS_allClasses_"$ID".RData
    OUTPUTFOLDER="$RESULTFOLDER"/LR_RHS/noThinning/LR_RHS_newTransformation

    CLASS=$1

    P0=300

    #List of input arguments
    #1 Data split ID
    #2 Filename into which the FeatureList object has been stored, with whole path
    #3 Thinned data file
    #4 Output folder and file name id
    #5 For which class the model is being trained (index)
    #6 Data splits file
    #7 Parameter p0
    #8 new (1) or old (0) transformation

    TRANSFORMATION=1

    srun Rscript --no-save train_LR_RHS_noThinning.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $TRANSFORMATION

else

    echo 'Wrong amount of arguments'

fi
