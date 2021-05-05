#Training logistic regression model with RHS prior

set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3 Thinned data file
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
load(args[3]) #Load thinned data
load(args[6]) #Load data splits file


ID=strtoi(args[1])
CLASS=strtoi(args[5])


#Data normalization with respect to the total read counts
wholeData_thinned <- normalizecounts_scale(wholeData_thinned)

if(strtoi(args[8])==0){
  wholeData_thinned <- log2(wholeData_thinned * 0.3 + 1e-6)
}else{
  wholeData_thinned <- log2(wholeData_thinned * 0.3 + 0.5)
}

pairsplot <- 0 #By default the pairs plot is not plotted

ourModel.onevEach <- train_LR_RHS_model(Mat = wholeData_thinned, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[ID]], FeatureList=FeatureList, index=CLASS, parameter_P0=strtoi(args[7]),pairsPlot=pairsplot,dataSplitID=ID)

save(ourModel.onevEach, file = paste(args[4], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
