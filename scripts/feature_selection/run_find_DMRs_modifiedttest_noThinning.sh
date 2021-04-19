#!/bin/sh -l
#SBATCH --time=15:00:00
#SBATCH --mem-per-cpu=70G
#SBATCH --job-name=cfDNA_pipeline_DMR_finding
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0

module load r/3.6.1-python3

NDMR=300

DATAFOLDER=...
RESULTFOLDER=...
 
INPUTFILE="$DATAFOLDER"/wholeData.RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_noThinning.RData

ID=$SLURM_ARRAY_TASK_ID

OUTPUTFOLDER="$RESULTFOLDER"/DMRs/noThinning/DMRs

OUTPUTFILE="$OUTPUTFOLDER"/found_DMRS_allClasses_"$ID".RData
OUTPUTFILE_T="$OUTPUTFOLDER"/found_DMRS_allClasses_top_"$ID".RData
OUTPUTFILE_B="$OUTPUTFOLDER"/found_DMRS_allClasses_bottom_"$ID".RData

#Arguments to the script
#List of input arguments
#1 Data split ID
#2 Filename into which to store the FeatureList object, with whole path
#3 Whole thinned data file name with path
#4 Data splits file
#5 File name into which the top DMRs are stored
#6 File name into which the bottom DMRs are stored
#7 number of DMRs to be saved into a file
#8 new (1) or old (0) transformation

srun Rscript --no-save find_DMRs_modifiedttest_newTransformation_noThinning.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $OUTPUTFILE_T $OUTPUTFILE_B $NDMR 0


