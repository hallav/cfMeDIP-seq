#!/bin/sh -l
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100

#When running this script one must give one input parameter: the class number (1-8) for which the classifyer is trained

if (($#==1)); then

    THINNING=6 #set to 4, 5 or 6

    DATAFOLDER=...
    RESULTFOLDER=...

    INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
    DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData

    ID=$SLURM_ARRAY_TASK_ID

    DMRFILE="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/Fishers_exact_test/found_DMRS_allClasses_"$ID".RData
    OUTPUTFOLDER="$RESULTFOLDER"/LR_RHS/sameReadcount10_"$THINNING"_Fisher

    CLASS=$1

    P0=300

    TRANSFORMATION=0 #Use the original data transformation

    srun Rscript --no-save train_LR_RHS.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $TRANSFORMATION

else

    echo 'Wrong amount of arguments'

fi
