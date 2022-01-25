#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 File path and name template where fitted glmnet models are stored
#2 Filename into which to store the AUC plot for glmnet, with whole path
#3 Filename and path for data splits file
#4 Filename and path for the data object
#5 Filename into which to store the PRAUC plot for glmnet model, with whole path
#6 save plots (the plotting part was removed from the script as the figures are not used in the manuscript)
#7 save AUC and AUPRC values into a file
#8  AUC file name (if 10==0 this is not used)
#9 old (0) or new (1) transformation

#Test that the number of input arguments is correct
if (length(args)!=9) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}


source("AUC_calculation_methods.R")

load(args[3])
load(args[4])

if(strtoi(args[9])==0){
  BrainData.matrix <- log2(BrainData.matrix * 0.3 + 1e-6)
}else{
  BrainData.matrix <- log2(BrainData.matrix * 0.3 + 0.5)
}


#Adapted from MachineLearning_Final.html from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
Classes.df <- dataSplits$df
TestPerformance.list <- list()

AllClasses.v <- unique(Classes.df$Classes)
N_classes <- length(AllClasses.v)

ourModelList <- list()

#Go over data splits
for(i in 1:100){
    print(paste("Data split ", i,sep=""))

    load(paste(args[1],i, ".RData",sep=""))

    TestPerformance.list[[i]] <- PredFunction(ModelList = AllIterations.onevEach,
                                            TestData = BrainData.matrix, Indices = dataSplits$samples[[i]], classes.df = Classes.df)

}

#Calculating Area under ROC curves
AUCs.DiscoveryCohort <- GetAUC.ClassWise.braindata(TestPerformance.list)

#Calculating Area under precision-recall curves
PRAUCs.DiscoveryCohort <- GetAUPRC.ClassWise.braindata(TestPerformance.list)



#Save AUC and PRAUC values into a file
if(strtoi(args[7])==1){

  AUC.medians.GLMNET <- rep(0,N_classes)
  AUC.IDs <- rep(0,N_classes)
  AUPRC.medians.GLMNET <- rep(0,N_classes)

  AUC.25q.GLMNET <- rep(0,N_classes)
  AUPRC.25q.GLMNET <- rep(0,N_classes)

  AUC.75q.GLMNET <- rep(0,N_classes)
  AUPRC.75q.GLMNET <- rep(0,N_classes)
  
  CLASSES<-c("BrainMets" ,"Hemangiopericytoma","Meningioma","NE","WT.Glioma","MUT.Glioma")

  for(i in 1:N_classes){
    AUC.medians.GLMNET[i] <- median(AUCs.DiscoveryCohort$AUC[AUCs.DiscoveryCohort$ID==CLASSES[i]])

    AUPRC.medians.GLMNET[i] <- median(PRAUCs.DiscoveryCohort$AUC[AUCs.DiscoveryCohort$ID==CLASSES[i]])

    AUC.25q.GLMNET[i] <- quantile(AUCs.DiscoveryCohort$AUC[AUCs.DiscoveryCohort$ID==CLASSES[i]],0.25)

    AUPRC.25q.GLMNET[i] <- quantile(PRAUCs.DiscoveryCohort$AUC[AUCs.DiscoveryCohort$ID==CLASSES[i]],0.25)

    AUC.75q.GLMNET[i] <- quantile(AUCs.DiscoveryCohort$AUC[AUCs.DiscoveryCohort$ID==CLASSES[i]],0.75)

    AUPRC.75q.GLMNET[i] <- quantile(PRAUCs.DiscoveryCohort$AUC[AUCs.DiscoveryCohort$ID==CLASSES[i]],0.75)

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
