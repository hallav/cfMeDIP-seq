#This script runs binarized ISPCA for the nonthinned data.
#Note that files StartingPoints.RData and featureSelection_methods.R must be in the same folder as this script (or whole path should be defined).


set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data	split ID
#2 Filename into which to store	the PCA results	object, with whole path
#3 Whole thinned data file name with path
#4 Data splits file
#5 DMR file
#6 Use DMR information or not
#7 Normalize ISPCA components or not

#Test that the number of input arguments is correct
if (length(args)!=7) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("featureSelection_methods.R")

INPUT_FILE=args[3]
DATASPLITS_FILE=args[4]

load(INPUT_FILE)

DataMatrix <- wholeData$datamatrix
rm(wholeData)


load(DATASPLITS_FILE)

#Load DMR file if needed
if (strtoi(args[6])==1){
  load(args[5])
}

ID=strtoi(args[1])

#Data normalization with respect to the total read counts
DataMatrix <- normalizecounts_scale(DataMatrix)

#Remove all-zero rows from DataMatrix
DataMatrix <- DataMatrix[rowSums(DataMatrix)>0,]

load("StartingPoints.RData")
rn <- rownames(Combined)
rm(Combined)
DataMatrix <- DataMatrix[rownames(DataMatrix) %in% rn,]
rm(rn)


PCA_result_list <- list()

AllClasses <- unique(dataSplits$df$Classes)

if (strtoi(args[7])==1){
 normalize_components=TRUE
}else{
 normalize_components=FALSE
}


if (strtoi(args[6])==1){
  #ISPCA using DMRs
  for(i in 1:length(AllClasses)){
    PCA_results <- ISPCA_allWindows(DataMatrix,classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList=FeatureList, class=i, transform=1,NC=length(dataSplits$samples[[ID]])-1,NORMALIZE=normalize_components,binarize=1) 
    PCA_result_list[[i]] <- PCA_results
  }
    
}else{
  #ISPCA without using DMRs
  for(i in 1:length(AllClasses)){
    PCA_results <- ISPCA_allWindows(DataMatrix, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList=NULL, class=i, transform=1,NC=length(dataSplits$samples[[ID]])-1,NORMALIZE=normalize_components,binarize=1)
    PCA_result_list[[i]] <- PCA_results
  }

}

save(PCA_result_list, file=args[2])



