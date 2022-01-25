.libPaths("/scratch/work/hallav1/R_3_6_1")
Sys.setenv(R_LIBS="/scratch/work/hallav1/R_3_6_1")


#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 File path and name template where fitted Stan models are stored
#2 Filename into which to store the AUC plot for our model, with whole path
#3 Filename into which to store the PRAUC plot for our model, with whole path
#4 save plots (plotting was removed as these plots are not used in the manuscript)
#5 save AUC and AUPRC values into a file
#6 AUC file name (if 10==0 this is not used)
#7 Filename and path for data splits file

#Test that the number of input arguments is correct
if (length(args)!=7) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}


source("AUC_calculation_methods.R")

load(args[8])


#Adapted from MachineLearning_Final.html from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
Classes.df <- dataSplits$df

AllClasses.v <- unique(Classes.df$Classes)
N_classes<-length(AllClasses.v)
ourModelList <- list()

#Go over data splits
for(i in 1:100){
    print(paste("Data split ", i,sep=""))

    iter <-list()
    #Go over each class
    for(j in 1:length(AllClasses.v)){
      print(paste("Class ", j,sep=""))

      #Load model and test set results
      load(paste(args[1],"_ID",i,"_CLASS",j,".RData",sep=""))
      DF <-data.frame(One=ourModel.onevEach$testDataResults$predictedClass, Others=1-ourModel.onevEach$testDataResults$predictedClass, ActualClass= ourModel.onevEach$testDataResults$trueClassName, PredictedClass=ifelse(ourModel.onevEach$testDataResults$predictedClass > 0.5,"One","Others"))
      iter[[j]] <- DF
    
    }
    names(iter) <- AllClasses.v
    ourModelList[[i]] <- iter

}
print(ourModelList[[1]])

#Calculating Area Under ROC curves
AUCs.DiscoveryCohort.ourmodel <-GetAUC.ClassWise.braindata(ourModelList)

#Calculating Area under precision-recall curves
PRAUCs.DiscoveryCohort.ourmodel <-GetAUPRC.ClassWise.braindata(ourModelList)

#Save AUC and PRAUC values into a file
if(strtoi(args[5])==1){


  AUC.medians.LR_RHS <- rep(0,N_classes)
  AUC.IDs <- rep(0,N_classes)
  AUPRC.medians.LR_RHS <- rep(0,N_classes)
  
  AUC.25q.LR_RHS <- rep(0,N_classes)
  AUPRC.25q.LR_RHS <- rep(0,N_classes)
  
  AUC.75q.LR_RHS <- rep(0,N_classes)
  AUPRC.75q.LR_RHS <- rep(0,N_classes)

  CLASSES<-c("BrainMets" ,"Hemangiopericytoma","Meningioma","NE","WT.Glioma","MUT.Glioma")

  for(i in 1:N_classes){
    AUC.medians.LR_RHS[i] <- median(AUCs.DiscoveryCohort.ourmodel$AUC[AUCs.DiscoveryCohort.ourmodel$ID==CLASSES[i]])

    AUPRC.medians.LR_RHS[i] <- median(PRAUCs.DiscoveryCohort.ourmodel$AUC[AUCs.DiscoveryCohort.ourmodel$ID==CLASSES[i]])

    AUC.25q.LR_RHS[i] <- quantile(AUCs.DiscoveryCohort.ourmodel$AUC[AUCs.DiscoveryCohort.ourmodel$ID==CLASSES[i]],0.25)

    AUPRC.25q.LR_RHS[i] <- quantile(PRAUCs.DiscoveryCohort.ourmodel$AUC[AUCs.DiscoveryCohort.ourmodel$ID==CLASSES[i]],0.25)

    AUC.75q.LR_RHS[i] <- quantile(AUCs.DiscoveryCohort.ourmodel$AUC[AUCs.DiscoveryCohort.ourmodel$ID==CLASSES[i]],0.75)

    AUPRC.75q.LR_RHS[i] <- quantile(PRAUCs.DiscoveryCohort.ourmodel$AUC[AUCs.DiscoveryCohort.ourmodel$ID==CLASSES[i]],0.75)

    AUC.IDs[i] <- CLASSES[i]
  }


  AUC.median.df <- data.frame(
    AUC_median=c(AUC.medians.LR_RHS),
    AUPRC_median=c(AUPRC.medians.LR_RHS),
    AUC_25q=c(AUC.25q.LR_RHS),
    AUPRC_25q=c(AUPRC.25q.LR_RHS),
    AUC_75q=c(AUC.75q.LR_RHS),
    AUPRC_75q=c(AUPRC.75q.LR_RHS),
    method=rep(c("ourMethod"),each=length(CLASSES)),
    classname=CLASSES)

  save(AUC.median.df, file = args[6],compress="xz")

}
