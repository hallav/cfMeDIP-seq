#This script is used to combine the counts for each sample in the validation cohort into one data matrix.
#The paths to directories and files must be defined before running

source("data_utilities.R")

DATAPATH<-"..." #Path to directory where there are subdirectories for each class (containing the sample count files)
OUTPUTFOLDER <- "..." #Path to directory into which the resulting data matrix is stored.

WINDOWFILE<-"hg19_300bp_Windows.Rdata" #File containing coordinates for the genomic windows


CLASSFOLDER_VALIDATION<-c("cfMeDIP-Validation_AML","cfMeDIP-Validation_Control","cfMeDIP-Validation_LUC","cfMeDIP-Validation_PDAC")
CLASSES <- c("AML","Normal","LUC","PDAC")

validationData <- collectDataMatrix(DATAPATH,CLASSFOLDER_VALIDATION,CLASSES,WINDOWFILE,199)

save(validationData, file = paste(OUTPUTFOLDER,"/validationData.RData",sep=""))
