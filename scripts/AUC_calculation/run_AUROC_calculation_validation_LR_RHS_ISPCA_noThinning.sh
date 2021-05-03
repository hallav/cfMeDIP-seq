#!/bin/sh -l
#SBATCH --time=30:00:00
#SBATCH --mem-per-cpu=25G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation_ISPCA_binary_validation
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

DATAFOLDER=...
RESULTFOLDER=...
 
INPUTFILE="$DATAFOLDER"/wholeData.RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_noThinning.RData
INPUTFILE_validation="$DATAFOLDER"/validationData.RData
INPUTFILE_training="$DATAFOLDER"/wholeData.RData
 
PCAFILE="$RESULTFOLDER"/DMRs/noThinning/ISPCA/ISPCA_DMR_results_dataSplit_

RESULTFOLDER_LR="$RESULTFOLDER"/LR_RHS/noThinning/LR_RHS_ISPCA
OUTPUTFOLDER="$RESULTFOLDER"/AUCs/noThinning/validation
MODELFILENAME="LR_RHS"

NAMEID="LR_ISPCA"
GP=0

#List of input arguments
#1 File path and name template where fitted Stan models are stored
#2 Filename and path for data splits file
#3 Filename and path for the whole data object
#4 Filename into which to store the AUC plot for our model, with whole path
#5 Filename into which to store the PRAUC plot for our model, with whole path
#6 save plots
#7 save AUC and AUPRC values into a file
#8 AUC file name (if 10==0 this is not used)
#9 GP (1) or LR (0)
#10 feature list
#11 PCA 0 or 1
#12 if 15==1, give the path+name of the PCA object
#13 Path where to write the ROC plots with averaged predictions (over data splits)
#14 old (0) or new (1) transformation
#15 file name of the whole validation data object
#16 ISPCA (1) or normal PCA (0)
#17 file name id
#18 standardize (IS)PCA components
#19 are there different PCA objects for each class (0 or 1)
#20 transform the data or not


VAR1="$RESULTFOLDER_LR"/"$MODELFILENAME"
VAR2=$DATASPLITFILE
VAR3=$INPUTFILE_training
VAR4="$OUTPUTFOLDER"/validation_AUC_plot_"$NAMEID"_01.eps
VAR5="$OUTPUTFOLDER"/validation_PRAUC_plot_"$NAMEID"_01.eps
VAR6=1
VAR7=1
VAR8="$OUTPUTFOLDER"/validation_AUC_values_"$NAMEID".RData
VAR9=0
VAR10="NA" #$FEATURELISTFILE
VAR11=1
VAR12=$PCAFILE
VAR13=$OUTPUTFOLDER
VAR14=1
VAR15=$INPUTFILE_validation
VAR16=1
VAR17=$NAMEID
VAR18=0
VAR19=0
VAR20=1

srun Rscript --no-save AUC_calculation_validation_noThinning.R $VAR2 $VAR4 $VAR5 $VAR6 $VAR8 $VAR9 $VAR10 $VAR11 $VAR12 $VAR14 $VAR15 $VAR16 $VAR17 $VAR18 $VAR19 $VAR20 $VAR21 $VAR22 $VAR23 $VAR24
