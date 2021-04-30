
set.seed(1234)


#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 Data split ID
#2 Filename into which the FeatureList object has been stored, with whole path
#3 Thinned data file
#4 Output folder and file name id
#5 Data splits file
#6 new (1) or old (0) transformation

#Test that the number of input arguments is correct
if (length(args)!=6) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("model_training_methods.R")

load(args[2]) #Load found DMRs i.e. FeatureList object
load(args[3]) #Thinned data
load(args[5]) #Data splits file


ID=strtoi(args[1])

if(strtoi(args[6])==0){
  wholeData_thinned <- log2(wholeData_thinned * 0.3 + 1e-6)
}else{
  #New data transformation
  wholeData_thinned <- log2(wholeData_thinned * 0.3 + 0.5)
}

AllIterations.onevEach <- train_GLMNet_model(wholeData_thinned, classes.df = dataSplits$df, Indices = dataSplits$samples[[ID]], FeatureList) 

save(AllIterations.onevEach, file = paste(args[4],ID,".RData",sep=""),compress="xz")
