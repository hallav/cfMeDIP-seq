#!/bin/sh -l
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_ISPCA_binary_braindata


#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

NORMALIZE=1

INPUTFILE=".../BrainData_6classes_datamatrix.RData"
DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"
ID=$SLURM_ARRAY_TASK_ID
DMRFILE="NA"

echo $ID

OUTPUTFOLDER=".../results/DMRs/ISPCA_binary"

OUTPUTFILE="$OUTPUTFOLDER"/ISPCA_DMR_results_dataSplit_"$ID".RData

#List of input arguments
#1 Data split ID
#2 Filename into which to store the PCA results object, with whole path
#3 Whole  data file name with path
#4 Data splits file
#5 DMR file
#6 Use DMR information or not
#7 normalize components or not

srun Rscript --no-save ISPCA_binary_intracranial_tumors.R  $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $DMRFILE 0 $NORMALIZE

