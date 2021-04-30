#!/bin/sh -l
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=30G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_noThinning
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

    DMRFILE="$RESULTFOLDER"/DMRs/noThinning/DMRs_Fisher/found_DMRS_allClasses_"$ID".RData
    OUTPUTFOLDER="$RESULTFOLDER"/LR_RHS/noThinning/LR_RHS_Fisher

    CLASS=$1

    P0=300

    TRANSFORMATION=0 #Use the original data transformation

    srun Rscript --no-save train_LR_RHS_noThinning.R $ID $DMRFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $TRANSFORMATION

else

    echo 'Wrong amount of arguments'

fi
