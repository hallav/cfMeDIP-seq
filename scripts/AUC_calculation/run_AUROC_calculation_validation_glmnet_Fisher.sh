#!/bin/sh -l
#SBATCH --time=07:00:00
#SBATCH --mem-per-cpu=15G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation_glmnet
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

THINNING=6 #set to 4, 5 or 6

INPUTFILE_training="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData
INPUTFILE_validation="$RESULTFOLDER"/validation_thinned_totalReadcount10_"$THINNING".RData
WHOLE_VALIDATION="$RESULTFOLDER"/validationData.RData

RESULTFOLDER_glmnet="$RESULTFOLDER"/GLMNET/totalReadcount10_"$THINNING"_Fisher
OUTPUTFOLDER="$RESULTFOLDER"/AUCs/totalReadcount10_"$THINNING"_validation

NAMEID="glmnet_Fisher"
GP=0

#List of input arguments
#1 File path and name template where fitted glmnet models are stored
#2 File path and name template where fitted Stan models are stored
#3 Filename into which to store the AUC plot for glmnet, with whole path
#4 Filename and path for data splits file
#5 Filename and path for the thinned data object
#6 Filename into which to store the AUC plot for our model, with whole path
#7 Filename into which to store the PRAUC plot for glmnet model, with whole path
#8 Filename into which to store the PRAUC plot for our model, with whole path
#9 save plots
#10 save AUC and AUPRC values into a file
#11 AUC file name (if 10==0 this is not used)
#12 GP (1) or LR (0)
#13 validation file
#14 feature list
#15 PCA 0 or 1
#16 if 15==1, give the path+name of the PCA object
#17 Path where to store the ROC plots with averaged predictions (over data splits)
#18 old (0) or new (1) transformation
#19 file name of the whole validation data object
#20 (non-DMR) ISPCA (1) or normal PCA (0)
#21 file name id
#22 standardize (IS)PCA components

VAR1="$RESULTFOLDER_glmnet"/wholeData_allClasses_10_glmnet_ID
VAR2="NA"
VAR3="NA"
VAR4=$DATASPLITFILE
VAR5=$INPUTFILE_training
VAR6="$OUTPUTFOLDER"/validation_AUC_plot_"$NAMEID"_01.eps 
VAR7="NA"
VAR8="$OUTPUTFOLDER"/validation_PRAUC_plot_"$NAMEID"_01.eps 
VAR9=1
VAR10=1
VAR11="$OUTPUTFOLDER"/validation_AUC_values_"$NAMEID".RData
VAR12=0
VAR13=$INPUTFILE_validation
VAR14="NA"
VAR15=0
VAR16="NA"
VAR17=$OUTPUTFOLDER
VAR18=0
VAR19=$WHOLE_VALIDATION
VAR20=0 
VAR21=$NAMEID
VAR22="NA"

srun Rscript --no-save AUC_calculation_validation_glmnet.R $VAR1 $VAR2 $VAR3 $VAR4 $VAR5 $VAR6 $VAR7 $VAR8 $VAR9 $VAR10 $VAR11 $VAR12 $VAR13 $VAR14 $VAR15 $VAR16 $VAR17 $VAR18 $VAR19 $VAR20 $VAR21 $VAR22
