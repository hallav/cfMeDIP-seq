#!/bin/sh -l
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_train_ourModel_ISPCA
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100

if (($#==1)); then

    THINNING=4 #set to 4, 5 or 6

    DATAFOLDER=...
    RESULTFOLDER=...

    INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
    DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData

    ID=$SLURM_ARRAY_TASK_ID

    PCAFILE="$RESULTFOLDER"/DMRs/newDataSplits/totalReadcount10_"$THINNING"/newTransformation/ISPCA_without_DMRs_normalized/ISPCA_DMR_results_dataSplit_"$ID".RData
    OUTPUTFOLDER="$RESULTFOLDER"/LR_RHS/newDataSplits/totalReadcount10_"$THINNING"_ISPCA_normalized
    PLOTFOLDER=$OUTPUTFOLDER

    CLASS=$1

    P0=100
    N_COMPONENTS=153

    #List of input arguments
    #1 Data split ID
    #2 Filename into which the PCA result object has been stored, with whole path
    #3 Thinned data file
    #4 Output folder and file name id
    #5 For which class the model is being trained (index)
    #6 Data splits file
    #7 Parameter p0
    #8 Number of components to be used
    #9 Folder where to store (debug) plots
    #10 were DMRs used or not

    srun Rscript --no-save train_LR_RHS_ISPCA.R $ID $PCAFILE $INPUTFILE "$OUTPUTFOLDER"/LR_RHS_ID $CLASS $DATASPLITFILE $P0 $N_COMPONENTS $PLOTFOLDER 0

else

    echo 'Wrong amount of arguments'

fi
