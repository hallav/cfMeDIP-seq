#Training logistic regression model with RHS prior
#The files StartingPoints.RData and featureSelection_methods.R  have to be in the same folder as this script (or whole path defined)

set.seed(1234)


#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3 Input data file
#4 Output folder and file name id
#5 For which class the model is being trained (index)
#6 Data splits file
#7 Parameter p0
#8 new (1) or old (0) transformation

#Test that the number of input arguments is correct
if (length(args)!=8) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("featureSelection_methods.R")

load(args[2]) #Load found DMRs i.e. FeatureList object
load(args[3]) #Load whole data
DM <- wholeData$datamatrix
rm(wholeData)
load(args[6]) #Load data splits file


load("StartingPoints.RData")
rn <- rownames(Combined)
rm(Combined)
DM <- DM[rownames(DM) %in% rn,]
rm(rn)


ID=strtoi(args[1])
CLASS=strtoi(args[5])


#Data normalization with respect to the total read counts
DM <- normalizecounts_scale(DM)

#Do the same transformation as in MachineLearning_Final.html
if(strtoi(args[8])==0){
  DM <- log2(DM * 0.3 + 1e-6)
}else{
  DM <- log2(DM * 0.3 + 0.5)
}

pairsplot <- 0 #By default the pairs plot is not plotted

ourModel.onevEach <- train_LR_RHS_model(Mat = DM, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[ID]], FeatureList=FeatureList, index=CLASS, parameter_P0=strtoi(args[7]),pairsPlot=pairsplot,dataSplitID=ID)

save(ourModel.onevEach, file = paste(args[4], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
