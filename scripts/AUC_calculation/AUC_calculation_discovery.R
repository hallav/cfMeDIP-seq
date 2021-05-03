#Note that files OnevAllClassifiers.R and AUC_calculation_methods.R  must be in the same folder as this script (or whole path should be defined).

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence

#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 File path and name template where fitted LR models are stored
#2 Filename and path for data splits file
#3 save AUC and AUPRC values into a file
#4 AUC file name (if 3==0 this is not used)

#Test that the number of input arguments is correct
if (length(args)!=4) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("OnevAllClassifiers.R")
source("AUC_calculation_methods.R")

load(args[4])

classInformation <- dataSplits$df

AllClasses.v <- unique(classInformation$Classes)

ourModelPredictions <- list()

#Go over data splits
for(i in 1:100){ #placeholder loop

    predictionsAllClasses <-list()
    #Go over each class
    for(j in 1:length(AllClasses.v)){
      #Load model and test set results
      load(paste(args[2],"_ID",i,"_CLASS",j,".RData",sep=""))
      DF <-data.frame(One=ourModel.onevEach$testDataResults$predictedClass, Others=1-ourModel.onevEach$testDataResults$predictedClass, ActualClass= ourModel.onevEach$testDataResults$trueClassName, PredictedClass=ifelse(ourModel.onevEach$testDataResults$predictedClass > 0.5,"One","Others"))
      predictionsAllClasses[[j]] <- DF
    
    }
    names(predictionsAllClasses) <- AllClasses.v
    ourModelPredictions[[i]] <- predictionsAllClasses

}


AUCs <-GetAUC.ClassWise2(ourModelPredictions) #This function is defined in OnevAllClassifiers.R

PRAUCs <-calculate_AUPRC_discovery(ourModelPredictions) #This function is defined in AUC_calculation_methods.R


#Save AUC and PRAUC values into a file

if(strtoi(args[10])==1){

  AUC.medians.LR_RHS <- rep(0,8)
  AUC.IDs <- rep(0,8)
  AUPRC.medians.LR_RHS <- rep(0,8)

  AUC.25q.LR_RHS <- rep(0,8)
  AUPRC.25q.LR_RHS <- rep(0,8)

  AUC.75q.LR_RHS <- rep(0,8)
  AUPRC.75q.LR_RHS <- rep(0,8)

  CLASSES<-c("AML","BRCA","CRC","PDAC","BLCA","Normal","LUC","RCC")

  for(i in 1:8){
    AUC.medians.LR_RHS[i] <- median(AUCs$AUC[AUCs$ID==CLASSES[i]])

    AUPRC.medians.LR_RHS[i] <- median(PRAUCs$AUC[AUCs$ID==CLASSES[i]])

    AUC.25q.LR_RHS[i] <- quantile(AUCs$AUC[AUCs$ID==CLASSES[i]],0.25)

    AUPRC.25q.LR_RHS[i] <- quantile(PRAUCs$AUC[AUCs$ID==CLASSES[i]],0.25)

    AUC.75q.LR_RHS[i] <- quantile(AUCs$AUC[AUCs$ID==CLASSES[i]],0.75)

    AUPRC.75q.LR_RHS[i] <- quantile(PRAUCs$AUC[AUCs$ID==CLASSES[i]],0.75)


    AUC.IDs[i] <- CLASSES[i]
  }


  AUC.median.df <- data.frame(
    AUC_median=AUC.medians.LR_RHS,
    AUPRC_median=AUPRC.medians.LR_RHS,
    AUC_25q=AUC.25q.LR_RHS,,
    AUPRC_25q=AUPRC.25q.LR_RHS,
    AUC_75q=AUC.75q.LR_RHS,
    AUPRC_75q=AUPRC.75q.LR_RHS,
    classname=CLASSES)

  save(AUC.median.df, file = args[11],compress="xz")

}
