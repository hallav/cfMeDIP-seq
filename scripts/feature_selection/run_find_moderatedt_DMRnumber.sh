#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_DMR_finding
#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

#Change the NDMR, FILEID and THINNING to generate all needed DMR sets
NDMR=400 #The number of DMRS picked for one class vs. one class comparison
FILEID=200 #File naming is based on the number of hypo/hypermethylated DMRs picked for one class vs. one class comparison
THINNING="10_4"

INPUTFILE=".../results/thinneddata/wholedata_thinned_allClasses_sameReadcount"$THINNING".RData"
DATASPLITFILE=".../results/datasplits/dataSplits_sameReadcount_"$THINNING".RData"
ID=$SLURM_ARRAY_TASK_ID

OUTPUTFOLDER=.../results/DMRs/sameReadcount"$THINNING"/newTransformation/featureN"$FILEID"

OUTPUTFILE="$OUTPUTFOLDER"/found_DMRS_allClasses_"$ID".RData
OUTPUTFILE_T="$OUTPUTFOLDER"/found_DMRS_allClasses_top_"$ID".RData
OUTPUTFILE_B="$OUTPUTFOLDER"/found_DMRS_allClasses_bottom_"$ID".RData

TRANSFORMATION=1 #generate DMRs with new version of the data transformation

srun Rscript --no-save  find_DMRs_modifiedttest_newTransformation.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $OUTPUTFILE_T $OUTPUTFILE_B $NDMR $TRANSFORMATION

