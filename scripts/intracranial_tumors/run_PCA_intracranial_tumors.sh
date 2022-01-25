#!/bin/sh -l
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=5G
#SBATCH --job-name=cfDNA_pipeline_PCA_DMR


#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3


INPUTFILE=".../BrainData_6classes_datamatrix.RData"
DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"
ID=$SLURM_ARRAY_TASK_ID
DMRFILE=".../results/DMRs/modifiedt_newTransformation/found_DMRS_allClasses_"$ID".RData"
OUTPUTFOLDER=".../results/DMRs/braindata/PCA"

OUTPUTFILE="$OUTPUTFOLDER"/PCA_results_dataSplit_"$ID".RData
srun Rscript --no-save PCA_intracranial_tumors.R  $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $DMRFILE

