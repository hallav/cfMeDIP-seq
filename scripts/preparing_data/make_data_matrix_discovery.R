#This script is used to combine the counts for each sample in the discovery cohort into one data matrix.
#The paths to directories and files must be defined before running

source("data_utilities.R")

DATAPATH<-"..." #Path to directory containing separate folders for each class (containing sample count files)

OUTPUTFOLDER<-"..." #Where to write the data matrix

WINDOWFILE<-"hg19_300bp_Windows.Rdata" #A file which contains the genomic window coordinates

CLASSFOLDERS<-c("cfMeDIP-AML","cfMeDIP-BRCA","cfMeDIP-CRC","cfMeDIP-PDAC","cfMeDIP-BL","cfMeDIP-Control","cfMeDIP-Lung","cfMeDIP-RCC")
CLASSES<-c("AML","BRCA","CRC","PDAC","BL","Control","Lung","RCC")

wholeData <- collectDataMatrix(DATAPATH,CLASSFOLDERS,CLASSES,WINDOWFILE,189)

save(wholeData, file = paste(OUTPUTFOLDER, "/wholeData.RData", sep=""))
