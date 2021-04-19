#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=30G
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
 
INPUTFILE="$DATAFOLDER"/wholeData.RData
DATASPLITFILE="$RESULTFOLDER"/datasplits/dataSplits_noThinning.RData

ID=$SLURM_ARRAY_TASK_ID
DMRFILE="$RESULTFOLDER"/DMRs/noThinning/DMRs_newTransformation/found_DMRS_allClasses_"$ID".RData

OUTPUTFOLDER="$RESULTFOLDER"/DMRs/newDataSplits/noThinning/PCA

OUTPUTFILE="$OUTPUTFOLDER"/PCA_results_dataSplit_"$ID".RData

srun Rscript --no-save PCA_onlyDMRs_noThinning.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $DMRFILE

