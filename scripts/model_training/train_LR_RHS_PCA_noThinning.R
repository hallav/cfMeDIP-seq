#Training logistic regression model with RHS prior using PCA components as features, using the non-thinned data
#The files StartingPoints.RData and model_training_methods.R have to be in the same folder as this script (or whole path defined)

set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the PCA result object has been stored, with whole path
#3 Thinned data file
#4 Output folder and file name id
#5 For which class the model is being trained (index)
#6 Data splits file
#7 Parameter p0
#8 Number of components to be used
#9 Folder where to store (debug) plots

#Test that the number of input arguments is correct
if (length(args)!=9) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("model_training_methods.R")

load(args[2]) #Load PCA object
load(args[3]) #Load thinned data
load(args[6]) #Load data splits file

DataMatrix <- wholeData$datamatrix
rm(wholeData)
 
 
load("StartingPoints.RData")
rn <- rownames(Combined)
rm(Combined)
DataMatrix <- DataMatrix[rownames(DataMatrix) %in% rn,]
rm(rn)

ID=strtoi(args[1])
CLASS=strtoi(args[5])

#Data normalization with respect to the total read counts
DataMatrix <- normalizecounts_scale(DataMatrix)
#Remove all-zero rows from DataMatrix
DataMatrix <- DataMatrix[rowSums(DataMatrix)>0,]

#Apply new transformation of the data before giving it as an input to the model fitting
DataMatrix <- log2(DataMatrix * 0.3 + 0.5)

pairsplot <- 0 #By default the pairs plot is not plotted
debugplots <- 0

ourModel.onevEach <- train_LR_RHS_model_PCA_features(Mat = DataMatrix, classInformation = dataSplits$df, TrainIndices = dataSplits$samples[[ID]], index=CLASS, parameter_P0=strtoi(args[7]), pca_results=PCA_result_list[[CLASS]], N_components=strtoi(args[8]), pairsPlot=pairsplot, FigFolder=args[9], dataSplitID=ID, debug=debugplots, ISPCA=0, normalize_pca=1)

save(ourModel.onevEach, file = paste(args[4], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
