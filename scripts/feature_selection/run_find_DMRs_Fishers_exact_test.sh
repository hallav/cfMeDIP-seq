#!/bin/sh -l
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_DMR_finding
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3

THINNING=6 #set to 4, 5 or 6

DATAFOLDER=...
RESULTFOLDER=...

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_sameReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_sameReadcount_10_"$THINNING".RData

ID=$SLURM_ARRAY_TASK_ID

OUTPUTFOLDER="$RESULTFOLDER"/DMRs/sameReadcount10_"$THINNING"/Fishers_exact_test

OUTPUTFILE="$OUTPUTFOLDER"/found_DMRS_allClasses_"$ID".RData
OUTPUTFILE_T="$OUTPUTFOLDER"/found_DMRS_allClasses_top_"$ID".RData
OUTPUTFILE_B="$OUTPUTFOLDER"/found_DMRS_allClasses_bottom_"$ID".RData

srun Rscript --no-save find_DMRs_Fishers_exact_test.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $OUTPUTFILE_T $OUTPUTFILE_B

