#Note that files StartingPoints.RData, OnevAllClassifiers.R and AUC_calculation_methods.R  must be in the same folder as this script (or whole path should be defined).

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697
#StartingPoints.RData file from Ankur Chakravarthy. (2018). Intermediate data objects from running the machine learning code for Shen et al, Nature, 2018 [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1490920 

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 File path and name template where fitted glmnet models are stored
#2 Filename into which to store the AUC plot for glmnet, with whole path
#3 Filename and path for data splits file
#4 Filename and path for the thinned data object
#5 Filename into which to store the PRAUC plot for glmnet model, with whole path
#6 Save plots (0 or 1) NOTE: these plots were not used in the manuscript, so the code was removed for clarity.
#7 save AUC and AUPRC values into a file
#8 AUC file name (if 10==0 this is not used)
#9 old (0) or new (1) transformation

#Test that the number of input arguments is correct
if (length(args)!=9) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("OnevAllClassifiers.R")
source("AUC_calculation_methods.R")

load(args[3])
load(args[4])

DataMatrix <- wholeData$datamatrix
rm(wholeData)
 
load("StartingPoints.RData")
rn <- rownames(Combined)
rm(Combined)
DataMatrix <- DataMatrix[rownames(DataMatrix) %in% rn,]
rm(rn)

if(strtoi(args[9])==0){
  DataMatrix <- log2(DataMatrix * 0.3 + 1e-6)
}else{
  DataMatrix <- log2(DataMatrix * 0.3 + 0.5)
}

classInformation <- dataSplits$df
model_predictions <- list()

AllClasses.v <- unique(classInformation$Classes)

ourModelList <- list()

#Go over data splits
for(i in 1:100){
    print(paste("Data split ", i,sep=""))

    load(paste(args[1],i, ".RData",sep=""))

    model_predictions[[i]] <- PredFunction(ModelList = AllIterations.onevEach, TestData = DataMatrix, Indices = dataSplits$samples[[i]], classes.df = classInformation)
}


AUCs <- GetAUC.ClassWise2(model_predictions) #This function is defined in OnevAllClassifiers.R

PRAUCs <- calculate_AUPRC_discovery(model_predictions) #This function is defined in AUC_calculation_methods.R



#Save AUC and PRAUC values into a file


if(strtoi(args[7])==1){

  AUC.medians.GLMNET <- rep(0,8)
  AUC.IDs <- rep(0,8)
  AUPRC.medians.GLMNET <- rep(0,8)

  AUC.25q.GLMNET <- rep(0,8)
  AUPRC.25q.GLMNET <- rep(0,8)

  AUC.75q.GLMNET <- rep(0,8)
  AUPRC.75q.GLMNET <- rep(0,8)

  CLASSES<-c("AML","BRCA","CRC","PDAC","BLCA","Normal","LUC","RCC")

  for(i in 1:8){
    AUC.medians.GLMNET[i] <- median(AUCs$AUC[AUCs$ID==CLASSES[i]])

    AUPRC.medians.GLMNET[i] <- median(PRAUCs$AUC[AUCs$ID==CLASSES[i]])

    AUC.25q.GLMNET[i] <- quantile(AUCs$AUC[AUCs$ID==CLASSES[i]],0.25)

    AUPRC.25q.GLMNET[i] <- quantile(PRAUCs$AUC[AUCs$ID==CLASSES[i]],0.25)

    AUC.75q.GLMNET[i] <- quantile(AUCs$AUC[AUCs$ID==CLASSES[i]],0.75)

    AUPRC.75q.GLMNET[i] <- quantile(PRAUCs$AUC[AUCs$ID==CLASSES[i]],0.75)

    AUC.IDs[i] <- CLASSES[i]
  }


  AUC.median.df <- data.frame(
    AUC_median=c(AUC.medians.GLMNET),
    AUPRC_median=c(AUPRC.medians.GLMNET),
    AUC_25q=c(AUC.25q.GLMNET),
    AUPRC_25q=c(AUPRC.25q.GLMNET),
    AUC_75q=c(AUC.75q.GLMNET),
    AUPRC_75q=c(AUPRC.75q.GLMNET),
    method=rep(c("glmnet"),each=length(CLASSES)),
    classname=rep(CLASSES))

  save(AUC.median.df, file = args[8],compress="xz")

}
