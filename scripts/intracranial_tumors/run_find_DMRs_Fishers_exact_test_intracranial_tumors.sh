#!/bin/sh -l
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --job-name=cfDNA_pipeline_DMR_finding


#SBATCH --array=1-100

cd /scratch/work/hallav1/cfDNA/scripts/wholeData

#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3


INPUTFILE=".../datasets/BrainData_6classes_datamatrix.RData"
DATASPLITFILE=".../results/datasplits/dataSplits_braindata.RData"
ID=$SLURM_ARRAY_TASK_ID

echo $ID

OUTPUTFOLDER=".../results/DMRs/braindata/DMRs_Fisher"

OUTPUTFILE="$OUTPUTFOLDER"/found_DMRS_allClasses_"$ID".RData
OUTPUTFILE_T="$OUTPUTFOLDER"/found_DMRS_allClasses_top_"$ID".RData
OUTPUTFILE_B="$OUTPUTFOLDER"/found_DMRS_allClasses_bottom_"$ID".RData
srun Rscript --no-save find_DMRs_Fishers_exact_test_intracranial_tumors.R $ID $OUTPUTFILE $INPUTFILE $DATASPLITFILE $OUTPUTFILE_T $OUTPUTFILE_B

