#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation_glmnet
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


THINNING=4 #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData

RESULTFOLDER_glmnet="$RESULTFOLDER"/GLMNET/totalReadcount10_"$THINNING"_newTransformation
OUTPUTFOLDER="$RESULTFOLDER"/AUCs/totalReadcount10_"$THINNING"

NAMEID_glmnet="glmnet_newTransformation"

#List of input arguments
#1 File path and name template where fitted glmnet models are stored
#2 Filename into which to store the AUC plot for glmnet, with whole path
#3 Filename and path for data splits file
#4 Filename and path for the thinned data object
#5 Filename into which to store the PRAUC plot for glmnet model, with whole path
#6 save plots
#7 save AUC and AUPRC values into a file
#8 AUC file name (if 10==0 this is not used)
#9 old (0) or new (1) transformation

VAR1="$RESULTFOLDER_glmnet"/wholeData_allClasses_10_glmnet_ID
VAR2="$OUTPUTFOLDER"/AUC_"$NAMEID_glmnet"_01.eps
VAR3=$DATASPLITFILE
VAR4=$INPUTFILE
VAR5="$OUTPUTFOLDER"/PRAUC_"$NAMEID_glmnet"_01.eps
VAR6=1
VAR7=1
VAR8="$OUTPUTFOLDER"/AUC_values_"$NAMEID_glmnet".RData
VAR9=1

srun Rscript --no-save AUC_calculation_discovery_glmnet.R $VAR1 $VAR2 $VAR3 $VAR4 $VAR5 $VAR6 $VAR7 $VAR8 $VAR9
