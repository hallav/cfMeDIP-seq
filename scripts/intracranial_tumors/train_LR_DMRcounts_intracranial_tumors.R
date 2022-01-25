#Script for running logistic regression with cauchy prior

set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path, TOP DMRS
#3 Filename into which the FeatureList object has been stored, with whole path, BOTTOM DMRS
#4 Data file
#5 Output folder and file name id
#6 For which class the model is being trained (index)
#7 Data splits file

#Test that the number of input arguments is correct
if (length(args)!=7) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("model_training_methods.R")

load(args[2]) #Load found DMRs i.e. FeatureList object TOP
load(args[3]) #Load found DMRs i.e. FeatureList object BOTTOM
load(args[4]) #Data
load(args[7]) #Data splits file


ID=strtoi(args[1])
CLASS=strtoi(args[6])


#Braindata does not have to be normalized based on total read counts as it is given as RPKM (in this case the total read counts are not even available)
ourModel.onevEach <- train_LR_DMRcount_model(BrainData.matrix, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList_top, FeatureList_bottom, CLASS,normalizeTotalReadscounts=0) 

save(ourModel.onevEach, file = paste(args[5], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
