#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_PCA_DMR
#SBATCH --mail-type=ALL
#SBATCH --mail-user=viivi.halla-aho@aalto.fi
#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0

module load r/3.6.1-python3

DATAFOLDER=...
RESULTFOLDER=...

THINNING=6 #set to 4, 5 or 6

INPUTFILE="$DATAFOLDER"/wholedata_thinned_allClasses_totalReadcount10_"$THINNING".RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_totalReadcount_10_"$THINNING".RData
ID=$SLURM_ARRAY_TASK_ID
DMRFILE="$RESULTFOLDER"/DMRs/totalReadcount10_"$THINNING"/newTransformation/found_DMRS_allClasses_"$ID".RData"

echo $ID

OUTPUTFOLDER=$RESULTFOLDER"/DMRs/totalReadcount10_"$THINNING"/newTransformation/PCA_with_DMRs

OUTPUTFILE="$OUTPUTFOLDER"/PCA_results_dataSplit_"$ID".RData
srun Rscript --no-save PCA_onlyDMRs.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $DMRFILE

