set.seed(1234)

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the PCA result object has been stored, with whole path
#3 Data file
#4 Output folder and file name id
#5 For which class the model is being trained (index)
#6 Data splits file
#7 Parameter p0
#8 Number of components to be used
#9 Folder where to store (debug) plots
#10 DMR-based/binarized ISPCA or not 

#Test that the number of input arguments is correct
if (length(args)!=10) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("model_training_methods.R")

load(args[2]) #Load PCA object
load(args[3]) #Data
load(args[6]) #Data splits file

ID=strtoi(args[1])
CLASS=strtoi(args[5])

BrainData.matrix <- BrainData.matrix[rowSums(BrainData.matrix)>0,]

BrainData.matrix <- log2(BrainData.matrix * 0.3 + 0.5)

pairsplot <- 0 #By default the pairs plot is not plotted

if(args[10]==1){
  PCA_OBJECT<-PCA_result_list[[CLASS]]
}else{
  PCA_OBJECT<-PCA_result_list[[1]] #If DMRs were not used, there is only one set of PCAs in the list object
}

ourModel.onevEach <- train_LR_RHS_model_PCA_features(Mat = BrainData.matrix, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], index=CLASS, parameter_P0=strtoi(args[7]), pca_results=PCA_OBJECT, N_components=strtoi(args[8]), pairsPlot=pairsplot, FigFolder=args[9], dataSplitID=ID,debug=0,ISPCA=1)

save(ourModel.onevEach, file = paste(args[4], ID,"_CLASS", CLASS,".RData",sep=""),compress="xz")
warnings()
