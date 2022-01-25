#!/bin/sh -l
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=15G
#SBATCH --job-name=cfDNA_pipeline_train_LR_DMRcounts_braindata


#SBATCH --array=1-100


#Updated the Perl and sqlite modules for R3.6.1
module load Perl/5.28.0-GCCcore-7.3.0
module load sqlite/3.28.0
module load r/3.6.1-python3


INPUTFILE=".../BrainData_6classes_datamatrix.RData"
DATASPLITFILE=".../results/dataSplits/dataSplits_braindata.RData"

ID=$SLURM_ARRAY_TASK_ID
OUTPUTFILE1=".../results/DMRs/DMRs_Fisher/found_DMRS_allClasses_top_"$SLURM_ARRAY_TASK_ID".RData" 
OUTPUTFILE2=".../results/DMRs/DMRs_Fisher/found_DMRS_allClasses_bottom_"$SLURM_ARRAY_TASK_ID".RData" 

OUTPUTFOLDER=".../results/LR_DMRcount/LR_DMRcount_Fisher"

ID=$SLURM_ARRAY_TASK_ID

for CLASS in {1..6}
do
    srun Rscript --no-save train_LR_DMRcounts_intracranial_tumors.R $ID $OUTPUTFILE1 $OUTPUTFILE2 $INPUTFILE "$OUTPUTFOLDER"/DMRcounts_allClasses_ID $CLASS $DATASPLITFILE
done
