#!/bin/sh -l
#SBATCH --time=05:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation_wPR
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


THINNING=4 #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData
RESULTFOLDER_LR="$RESULTFOLDER"/LR_RHS/totalReadcount10_"$THINNING"_ISPCA_normalized
OUTPUTFOLDER="$RESULTFOLDER"/AUCs/totalReadcount10_"$THINNING"
MODELFILENAME="LR_RHS"

NAMEID="LR_ISPCA_normalized"
TRANSFORMATION=1

#List of input arguments
#1 File path and name template where fitted LR models are stored
#2 Filename and path for data splits file
#3 save AUC and AUPRC values into a file
#4 AUC file name (if 10==0 this is not used)
 
I1="$RESULTFOLDER_LR"/"$MODELFILENAME"
I2=$DATASPLITFILE
I3=1
I4="$OUTPUTFOLDER"/AUC_values_"$NAMEID".RData
 
srun Rscript --no-save AUC_calculation_discovery.R $I1 $I2 $I3 $I4
 
