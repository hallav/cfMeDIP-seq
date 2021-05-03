#!/bin/sh -l
#SBATCH --time=07:00:00
#SBATCH --mem-per-cpu=15G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

THINNING=4  #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE_training="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData
INPUTFILE_validation="$RESULTFOLDER"/validation_thinned_sameReadcount10_"$THINNING".RData
WHOLE_VALIDATION="$RESULTFOLDER"/validationData.RData

FEATURELISTFILE_TOP="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/found_DMRS_allClasses_top_
FEATURELISTFILE_BOTTOM="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/found_DMRS_allClasses_bottom_

RESULTFOLDER_LR="$RESULTFOLDER"/LR_DMRcount/sameReadcount10_"$THINNING"
OUTPUTFOLDER="$RESULTFOLDER"/AUCs/newDataSplits/sameReadcount10_"$THINNING"_validation
MODELFILENAME="DMRcounts_allClasses"

NAMEID="LR_DMRcounts"

#1 File path and name template where fitted Stan models are stored
#2 Filename and path for data splits file
#3 Filename and path for the thinned data object
#4 Filename into which to store the AUC plot for our model, with whole path
#5 Filename into which to store the PRAUC plot for our model, with whole path
#6 save plots
#7 save AUC and AUPRC values into a file
#8 AUC file name (if 10==0 this is not used)
#9 thinned validation data object
#10 feature list TOP
#11 feature list BOTTOM
#12 Path where to write the ROC plots with averaged predictions (over data splits)
#13 file name of the whole validation data object
#14 file name id


VAR1="$RESULTFOLDER_LR"/"$MODELFILENAME"
VAR2="$DATASPLITFILE"
VAR3="$INPUTFILE_training"
VAR4="$OUTPUTFOLDER"/validation_AUC_plot_"$NAMEID"_01.eps
VAR5="$OUTPUTFOLDER"/validation_PRAUC_plot_"$NAMEID"_01.eps
VAR6=1
VAR7=1
VAR8="$OUTPUTFOLDER"/validation_AUC_values_"$NAMEID".RData
VAR9=$INPUTFILE_validation
VAR10="$FEATURELISTFILE_TOP"
VAR11="$FEATURELISTFILE_BOTTOM "
VAR12=$OUTPUTFOLDER
VAR13=$WHOLE_VALIDATION
VAR14=$NAMEID

srun Rscript --no-save AUC_calculation_validation_DMRcount.R $VAR1 $VAR2 $VAR3 $VAR4 $VAR5 $VAR6 $VAR7 $VAR8 $VAR9 $VAR10 $VAR11 $VAR12 $VAR13 $VAR14
