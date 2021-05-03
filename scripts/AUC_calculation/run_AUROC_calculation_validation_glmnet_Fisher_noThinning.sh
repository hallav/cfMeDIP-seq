#!/bin/sh -l
#SBATCH --time=07:00:00
#SBATCH --mem-per-cpu=30G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation_glmnet
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi

#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

DATAFOLDER=...
RESULTFOLDER=...
 
INPUTFILE_training="$DATAFOLDER"/wholeData.RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_noThinning.RData
WHOLE_VALIDATION="$DATAFOLDER/validationData.RData"

FEATURELISTFILE="$RESULTFOLDER/DMRs/noThinning/found_DMRS_allClasses_"

OUTPUTFOLDER_glmnet="$RESULTFOLDER/GLMNET/noThinning/glmnet_Fisher"
OUTPUTFOLDER="$RESULTFOLDER/AUCs/noThinning/validation"

NAMEID="glmnet_Fisher"
GP=0

#List of input arguments
#1 File path and name template where fitted glmnet models are stored
#2 Filename into which to store the AUC plot for glmnet, with whole path
#3 Filename and path for data splits file
#4 Filename and path for the thinned data object
#5 Filename into which to store the PRAUC plot for glmnet model, with whole path
#6 save plots
#7 save AUC and AUPRC values into a file
#8 AUC file name (if 10==0 this is not used)
#9 feature list
#10 PCA 0 or 1
#11 if 10==1, give the path+name of the PCA object
#12 Path where to write the ROC plots with averaged predictions (over data splits)
#13 old (0) or new (1) transformation
#14 file name of the whole validation data object
#15 file name id


VAR1="$OUTPUTFOLDER_glmnet"/wholeData_allClasses_10_glmnet_ID
VAR2="$OUTPUTFOLDER"/validation_AUC_plot_"$NAMEID"_01.eps
VAR3=$DATASPLITFILE
VAR4=$INPUTFILE_training
VAR5="$OUTPUTFOLDER"/validation_PRAUC_plot_"$NAMEID"_01.eps 
VAR6=1
VAR7=1
VAR8="$OUTPUTFOLDER"/validation_AUC_values_"$NAMEID".RData
VAR9="NA" #$FEATURELISTFILE
VAR10="NA"
VAR11="NA"
VAR12=$OUTPUTFOLDER
VAR13=0
VAR14=$WHOLE_VALIDATION
VAR15=$NAMEID

srun Rscript --no-save AUC_calculation_validation_glmnet_noThinning.R $VAR1 $VAR2 $VAR3 $VAR4 $VAR5 $VAR6 $VAR7 $VAR8 $VAR9 $VAR10 $VAR11 $VAR12 $VAR13 $VAR14 $VAR15
