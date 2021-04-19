#!/bin/sh -l
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=22G
#SBATCH --job-name=cfDNA_pipeline_ISPCA_binary
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

NORMALIZE=1

THINNING=4 #set to 4, 5 or 6

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE="NULL" #not used

echo $ID

OUTPUTFOLDER="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/newTransformation/ISPCA_without_DMRs_normalized_binarize

OUTPUTFILE="$OUTPUTFOLDER"/ISPCA_DMR_results_dataSplit_"$ID".RData

#List of input arguments
#1 Data split ID
#2 Filename into which to store the PCA results object, with whole path
#3 Whole thinned data file name with path
#4 Data splits file
#5 DMR file
#6 Use DMR information or not
#7 normalize components or not (was not used before 20.10.2020)

srun Rscript --no-save ISPCA_binarized.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $DMRFILE 0 $NORMALIZE

