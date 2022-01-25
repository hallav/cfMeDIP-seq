#!/bin/sh -l
#SBATCH --time=05:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_AUC_calculation_wPR_braindata



#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

INPUTFILE=".../BrainData_6classes_datamatrix.RData"
DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"

OUTPUTFOLDER_ourModel=".../results/LR_RHS/LR_RHS_newTransformation"
OUTPUTFOLDER=".../results/AUCs"
MODELFILENAME="LR_RHS"

NAMEID="LR_RHS_newTransformation"

#List of input arguments
#1 File path and name template where fitted Stan models are stored
#2 Filename into which to store the AUC plot for our model, with whole path
#3 Filename into which to store the PRAUC plot for our model, with whole path
#4 save plots
#5 save AUC and AUPRC values into a file
#6 AUC file name (if 10==0 this is not used)
#7 Filename and path for data splits file


I1="$OUTPUTFOLDER_ourModel"/"$MODELFILENAME"
I2="$OUTPUTFOLDER"/AUC_plot_"$NAMEID"_01.eps
I3="$OUTPUTFOLDER"/PRAUC_plot_"$NAMEID"_01.eps
I4=1
I5=1
I6="$OUTPUTFOLDER"/AUC_values_"$NAMEID".RData
I7=0
I8=$DATASPLITFILE

srun Rscript --no-save AUC_calculation_LR_intracranial_tumors.R $I1 $I2 $I3 $I4 $I5 $I6 $I7 $I8



