#Note that files OnevAllClassifiers.R and AUC_calculation_methods.R  must be in the same folder as this script (or whole path should be defined).

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence

#The code for making the validation data predictions is from the file MachineLearning_Final.html from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence.


#Arguments to the script
args <- commandArgs(TRUE)
#List of input arguments
#1 File path and name template where fitted glmnet models are stored
#2 File path and name template where fitted Stan models are stored
#3 Filename into which to store the AUC plot for glmnet, with whole path
#4 Filename and path for data splits file
#5 Filename and path for the thinned data object
#6 Filename into which to store the AUC plot for our model, with whole path
#7 Filename into which to store the PRAUC plot for glmnet model, with whole path
#8 Filename into which to store the PRAUC plot for our model, with whole path
#9 save AUC boxplots Note: the code for making the plots was removed for clarity, these figures were not used in the manuscript. 
#10 save AUC and AUPRC values into a file
#11 AUC file name (if 10==0 this is not used)
#12 GP (1) or LR (0)
#13 thinned validation data object
#14 feature list
#15 PCA 0 or 1
#16 if 15==1, give the path+name of the PCA object
#17 Path where to write the ROC plots with averaged predictions (over data splits) Note: the code for making the plots was removed for clarity, these figures were not used in the manuscript. The code for the ROC plots presented in the paper is in a separate script.
#18 old (0) or new (1) transformation
#19 file name of the whole validation data object
#20 (non-DMR) ISPCA (1) or normal PCA (0)
#21 file name id
#22 standardize (IS)PCA components

#Test that the number of input arguments is correct
if (length(args)!=22) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("OnevAllClassifiers.R")
source("AUC_calculation_methods.R")

if(strtoi(args[20])==1){
  library(dimreduce)
}

load(args[19])
validationClasses <- validationData$classes

#Removed for saving space
rm(validationData) 


load(args[4])
load(args[5])

#Do the transformation to training data
if(strtoi(args[18])==0){
  wholeData_thinned_training <- log2(wholeData_thinned * 0.3 + 1e-6)
}else{
  wholeData_thinned_training <- log2(wholeData_thinned * 0.3 + 0.5)
}


rm(wholeData_thinned)

load(args[13])
val.rownames<-rownames(wholeData_thinned)

#Do the transformation to validation data
if(strtoi(args[18])==0){
  wholeData_thinned_validation <- log2(wholeData_thinned * 0.3 + 1e-6)
}else{
  wholeData_thinned_validation <- log2(wholeData_thinned * 0.3 + 0.5)
}

rm(wholeData_thinned)


classInformation <- dataSplits$df

AllClasses.v <- unique(classInformation$Classes)


CLASSES<-c("AML","BRCA","CRC","PDAC","BL","Control","Lung","RCC")
CLASSES_V<-c("AML","BRCA","CRC","PDAC","BL","Normal","LUC","RCC")

CLASSLIST_num <- c(1,7,4,6)
CLASSLIST <- CLASSES[CLASSLIST_num]
CLASSLIST_V <- CLASSES_V[CLASSLIST_num]


N_SPLITS <- 100

all_preds_4classes <- list()
iter_4classes <- list()


AllIterations.onevEach.ALL <- list()
#Load glmnet models
for(i in 1:N_SPLITS) {
  load(paste(args[1],i,".RData",sep=""))
  AllIterations.onevEach.ALL[[i]] <- AllIterations.onevEach
}

AML_models <- c(lapply(AllIterations.onevEach.ALL, function(x) x$AML))
AML_models <- lapply(AML_models, function(x) x$Model)
iter<-list()
all_preds <- matrix(nrow=N_SPLITS,ncol=ncol(wholeData_thinned_validation))
#AML
print("Predictions for AML group")
for(i in 1:N_SPLITS){
  print(i)
  Features <- AML_models[[i]]$finalModel$xNames
  ValData <- wholeData_thinned_validation[match(Features, val.rownames),]
  Predictions <- predict(AML_models[[i]], newdata = t(ValData), type ="prob")
  all_preds[i,]<-Predictions$One
  DF <-data.frame(One=Predictions$One, Others=Predictions$Others, ActualClass= validationClasses)
  iter[[i]] <- DF
}

iter_4classes[[1]] <- iter
all_preds_4classes[[1]] <- all_preds

#LUC
LUC_models <- c(lapply(AllIterations.onevEach.ALL, function(x) x$Lung))
LUC_models <- lapply(LUC_models, function(x) x$Model)
iter<-list()
all_preds <- matrix(nrow=N_SPLITS,ncol=ncol(wholeData_thinned_validation))
print("Predictions for LUC group")
for(i in 1:N_SPLITS) {
  print(i)
  Features <- LUC_models[[i]]$finalModel$xNames
  ValData <- wholeData_thinned_validation[match(Features, val.rownames),]
  Predictions <- predict(LUC_models[[i]], newdata = t(ValData), type ="prob")
  all_preds[i,]<-Predictions$One
  DF <-data.frame(One=Predictions$One, Others=Predictions$Others, ActualClass= validationClasses)
  iter[[i]] <- DF
}

iter_4classes[[2]] <- iter
all_preds_4classes[[2]] <- all_preds

#Normal
Normal_models <- c(lapply(AllIterations.onevEach.ALL, function(x) x$Control))
Normal_models <- lapply(Normal_models, function(x) x$Model)
iter<-list()
all_preds <- matrix(nrow=N_SPLITS,ncol=ncol(wholeData_thinned_validation))
print("Predictions for Normal group")
for(i in 1:length(Normal_models)) {
  print(i)
  Features <- Normal_models[[i]]$finalModel$xNames
  ValData <- wholeData_thinned_validation[match(Features, val.rownames),]
  Predictions <- predict(Normal_models[[i]], newdata = t(ValData), type ="prob")
  all_preds[i,]<-Predictions$One
  DF <-data.frame(One=Predictions$One, Others=Predictions$Others, ActualClass= validationClasses)
  iter[[i]] <- DF
}

iter_4classes[[4]] <- iter
all_preds_4classes[[4]] <- all_preds

#PDAC
PDAC_models <- c(lapply(AllIterations.onevEach.ALL, function(x) x$PDAC))
PDAC_models <- lapply(PDAC_models, function(x) x$Model)
iter<-list()
all_preds <- matrix(nrow=N_SPLITS,ncol=ncol(wholeData_thinned_validation))
print("Predictions for PDAC group")
for(i in 1:N_SPLITS) {
  print(i)
  Features <- PDAC_models[[i]]$finalModel$xNames
  ValData <- wholeData_thinned_validation[match(Features, val.rownames),]
  Predictions <- predict(PDAC_models[[i]], newdata = t(ValData), type ="prob")
  all_preds[i,]<-Predictions$One
  DF <-data.frame(One=Predictions$One, Others=Predictions$Others, ActualClass= validationClasses)
  iter[[i]] <- DF
}

iter_4classes[[3]] <- iter
all_preds_4classes[[3]] <- all_preds


names(iter_4classes) <- CLASSLIST_V


print("Calculate AUCs and PRAUCs")

AUCs <- list()
for(j in 1:length(CLASSLIST_V)){
  AUCs[[j]] <-calculate_AUC_validation(iter_4classes[[j]],CLASSLIST_V[j])
}


PRAUCs <- list()
for(j in 1:length(CLASSLIST_V)){
  PRAUCs[[j]] <-calculate_AUPRC_validation(iter_4classes[[j]],CLASSLIST_V[j])
}


print("Average over the data splits and make ROC plots for each class")

ClassProbs.AML <- colMeans(all_preds_4classes[[1]])
Class.AML <- ifelse(validationClasses == CLASSES_V[1], 1,0)

ClassProbs.LUC <- colMeans(all_preds_4classes[[2]])
Class.LUC <- ifelse(validationClasses == CLASSES_V[7], 1,0)

ClassProbs.PDAC <- colMeans(all_preds_4classes[[3]])
Class.PDAC <- ifelse(validationClasses == CLASSES_V[4], 1,0)

ClassProbs.Normal <- colMeans(all_preds_4classes[[4]])
Class.Normal <- ifelse(validationClasses == CLASSES_V[6], 1,0)

print("Make data frames")

ClassProbs.LUC <- data.frame(Probability = ClassProbs.LUC, Classes =Class.LUC, stringsAsFactors = F)
ClassProbs.AML <- data.frame(Probability = ClassProbs.AML, Classes =Class.AML, stringsAsFactors = F)
ClassProbs.Normal <- data.frame(Probability = ClassProbs.Normal, Classes =Class.Normal, stringsAsFactors = F)
ClassProbs.PDAC <- data.frame(Probability = ClassProbs.PDAC, Classes =Class.PDAC, stringsAsFactors = F)


ROC_list <- list(ClassProbs.LUC,ClassProbs.AML,ClassProbs.Normal,ClassProbs.PDAC)
save(ROC_list, file = paste(args[17],"/data_for_ROC_validation_",args[21],".RData",sep=""),compress="xz")

AUC_Bound <- rbind(AUCs[[1]],AUCs[[2]],AUCs[[3]],AUCs[[4]])
PRAUC_Bound <- rbind(PRAUCs[[1]],PRAUCs[[2]],PRAUCs[[3]],PRAUCs[[4]])


print("Save AUC and PRAUC values into a file")

N_classes <- length(CLASSLIST_V)
if(strtoi(args[10])==1){

  AUC.medians.GLMNET <- rep(0,N_classes)
  AUC.IDs <- rep(0,N_classes)
  AUPRC.medians.GLMNET <- rep(0,N_classes)

  AUC.25q.GLMNET <- rep(0,N_classes)
  AUPRC.25q.GLMNET <- rep(0,N_classes)

  AUC.75q.GLMNET <- rep(0,N_classes)
  AUPRC.75q.GLMNET <- rep(0,N_classes)

  for(i in 1:length(CLASSLIST_V)){
    AUC.medians.GLMNET[i] <- median(AUC_Bound$AUC[AUC_Bound$ID==CLASSLIST_V[i]])

    AUPRC.medians.GLMNET[i] <- median(PRAUC_Bound$AUC[PRAUC_Bound$ID==CLASSLIST_V[i]])

    AUC.25q.GLMNET[i] <- quantile(AUC_Bound$AUC[AUC_Bound$ID==CLASSLIST_V[i]],0.25)

    AUPRC.25q.GLMNET[i] <- quantile(PRAUC_Bound$AUC[PRAUC_Bound$ID==CLASSLIST_V[i]],0.25)

    AUC.75q.GLMNET[i] <- quantile(AUC_Bound$AUC[AUC_Bound$ID==CLASSLIST_V[i]],0.75)

    AUPRC.75q.GLMNET[i] <- quantile(PRAUC_Bound$AUC[PRAUC_Bound$ID==CLASSLIST_V[i]],0.75)


    AUC.IDs[i] <- CLASSLIST[i]
  }


  AUC.median.df <- data.frame(
    AUC_median=AUC.medians.GLMNET,
    AUPRC_median=AUPRC.medians.GLMNET,
    AUC_25q=AUC.25q.GLMNET,
    AUPRC_25q=AUPRC.25q.GLMNET,
    AUC_75q=AUC.75q.GLMNET,
    AUPRC_75q=AUPRC.75q.GLMNET,
    classname=CLASSLIST)

  save(AUC.median.df, file = args[11],compress="xz")

}
