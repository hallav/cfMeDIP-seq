#Script for running logistic regression with cauchy prior for the non-thinned data set.
#The file StartingPoints.RData model_training_methods.R needs to be in the same folder as this script (or path defined)

set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path, TOP DMRS
#3 Filename into which the FeatureList object has been stored, with whole path, BOTTOM DMRS
#4 Thinned data file
#5 Output folder and file name id
#6 For which class the model is being trained (index)
#7 Data splits file

#Test that the number of input arguments is correct
if (length(args)!=7) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("model_training_methods.R")

load(args[2]) #Load found DMRs: FeatureList object TOP
load(args[3]) #Load found DMRs: FeatureList object BOTTOM
load(args[4]) #Thinned data
load(args[7]) #Data splits file

DataMatrix <- wholeData$datamatrix
rm(wholeData)

load("StartingPoints.RData")
rn <- rownames(Combined)
rm(Combined)
DataMatrix <- DataMatrix[rownames(DataMatrix) %in% rn,]
rm(rn)


ID=strtoi(args[1])
CLASS=strtoi(args[6])


ourModel.onevEach <- train_LR_DMRcount_model(DataMatrix, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[ID]], FeatureList_top, FeatureList_bottom, CLASS)

save(ourModel.onevEach, file = paste(args[5], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
