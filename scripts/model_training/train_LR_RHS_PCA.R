#Training logistic regression model with RHS prior with PCA components as features

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

ID=strtoi(args[1])
CLASS=strtoi(args[5])


#Data normalization with respect to the total read counts
wholeData_thinned <- normalizecounts_scale(wholeData_thinned)
#Remove all-zero rows from wholeData_thinned
wholeData_thinned <- wholeData_thinned[rowSums(wholeData_thinned)>0,]

#Apply new transformation of the data before giving it as an input to the model fitting
wholeData_thinned <- log2(wholeData_thinned * 0.3 + 0.5)

pairsplot <- 0 #By default the pairs plot is not plotted
debugplots <- 0

ourModel.onevEach <- train_LR_RHS_model_PCA_features(Mat = wholeData_thinned, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], index=CLASS, parameter_P0=strtoi(args[7]), pca_results=PCA_result_list[[CLASS]], N_components=strtoi(args[8]), pairsPlot=pairsplot, FigFolder=args[9], dataSplitID=ID, debug=debugplots, ISPCA=0, normalize_pca=1)

save(ourModel.onevEach, file = paste(args[4], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
