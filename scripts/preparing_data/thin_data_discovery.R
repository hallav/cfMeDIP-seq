#Note that this file must be in the same directory as StartingPoints.RData and wholeData.RData (or whole path must be defined) 
#and output folder must be specified before running this script.

set.seed(1234)

args <- commandArgs(TRUE)
#Input arguments
READCOUNT <- strtoi(args[1])
FILENAMEID <- args[2]

source("data_utilities.R")

WHOLEDATA_FILE="wholeData.RData"

OUTPUT_FOLDER="..."

OUTPUT_FILE_NAME="wholedata_thinned_allClasses"

load(WHOLEDATA_FILE)

wholeData_thinned <- thinData_readnumber(wholeData$datamatrix,READCOUNT)


#Only save the 505027 features used in Shen et al. paper.
#Load combined object
load("StartingPoints.RData")
rn <- rownames(Combined)
rm(Combined)
wholeData_thinned <- wholeData_thinned[rownames(wholeData_thinned) %in% rn,]

save(wholeData_thinned, file = paste(OUTPUT_FOLDER,OUTPUT_FILE_NAME,"_",FILENAMEID,".RData",sep=""))
















