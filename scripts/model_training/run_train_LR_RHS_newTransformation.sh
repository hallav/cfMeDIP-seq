#!/bin/sh -l
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_LR_RHS_newTransformation
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100

#When running this script one must give one input parameter: the class number (1-8) for which the classifyer is trained

if (($#==1)); then

    THINNING=4  #set to 4, 5 or 6

    DATAFOLDER=...
    RESULTFOLDER=...

    INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
    DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData

    ID=$SLURM_ARRAY_TASK_ID

    DMRFILE="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/newTransformation/found_DMRS_allClasses_"$ID".RData
    OUTPUTFOLDER="$RESULTFOLDER"/LR_RHS/sameReadcount10_"$THINNING"_newTransformation

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

    srun Rscript --no-save train_LR_RHS.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $TRANSFORMATION

else

    echo 'Wrong amount of arguments'

fi
