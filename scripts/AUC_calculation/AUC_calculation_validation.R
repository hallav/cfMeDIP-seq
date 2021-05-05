#Note that files OnevAllClassifiers.R and AUC_calculation_methods.R  must be in the same folder as this script (or whole path should be defined).

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence

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
#20 ISPCA (1) or normal PCA (0)
#21 file name id
#22 standardize (IS)PCA components
#23 are there different PCA objects for each class 0 or 1 added on 9.12.2020
#24 transform the data or not


#Test that the number of input arguments is correct
if (length(args)!=24) {
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

wholeData_thinned_training <-wholeData_thinned
load(args[13])
wholeData_thinned_validation <- wholeData_thinned
rm(wholeData_thinned)

wholeData_thinned_validation <- normalizecounts_scale_validation(wholeData_thinned_training,wholeData_thinned_validation)
wholeData_thinned_training <- normalizecounts_scale(wholeData_thinned_training)

#Do the transformation to training data
if(strtoi(args[24])==1){
  if(strtoi(args[18])==0){
    wholeData_thinned_training <- log2(wholeData_thinned_training * 0.3 + 1e-6)
  }else{
    wholeData_thinned_training <- log2(wholeData_thinned_training * 0.3 + 0.5)
  }
 }else{
  print("No transformation.")
}


#Do the transformation to validation data
if(strtoi(args[24])==1){
  if(strtoi(args[18])==0){
    wholeData_thinned_validation <- log2(wholeData_thinned_validation * 0.3 + 1e-6)
  }else{
    wholeData_thinned_validation <- log2(wholeData_thinned_validation * 0.3 + 0.5)
  }
}else{
  print("No transformation.")
}


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

#Go over each class in validation data
for(J in 1:length(CLASSLIST)){
  print(paste("Class ", J,sep=""))
  j <- CLASSLIST_num[J] 

  all_preds <- matrix(nrow=N_SPLITS,ncol=ncol(wholeData_thinned_validation))
  iter<-list()

  #Go over data splits
  for(i in 1:N_SPLITS){
    print(paste("Data split ", i,sep=""))
    INDICES <- dataSplits$samples[[i]]

    #Load model and test set results
    if(strtoi(args[12])==0){
      load(paste(args[2],"_ID",i,"_CLASS",j,".RData",sep=""))
      N_features <- ncol(ourModel.onevEach$Samples$beta)
    }else{
      load(paste(args[2],i,"_CLASS",j,".RData",sep="")) #GP version
    }

    #Pick the features/PCA components and standardize the validation data
    if(strtoi(args[15])==0 && strtoi(args[12])==0){
      load(paste(args[14],i,".RData",sep=""))
      Features <- FeatureList[[j]]
      X_val <- as.matrix(t(wholeData_thinned_validation[rownames(wholeData_thinned_validation) %in% Features,]))
      X_val <- standardizecounts_validation(as.matrix(t(wholeData_thinned_training[rownames(wholeData_thinned_training) %in% Features,INDICES])),X_val)
      X_val <- t(X_val)

    }else{
      if(strtoi(args[15])==1){
        #load the PCA object
        load(paste(args[16],i,".RData",sep=""))
        if(strtoi(args[23])==0){
          pca_results <- PCA_result_list[[1]]
        }else{
          pca_results <- PCA_result_list[[j]]
        }
        X_val <- t(predict(pca_results, t(wholeData_thinned_validation)))
        X_val <- as.matrix(X_val[1:N_features,])
        if(strtoi(args[22])==1){
          X_train_temp <- t(as.matrix(predict(pca_results, t(wholeData_thinned_training))))
          X_val <- standardizecounts_validation_scale_only(X_train_temp[1:N_features,INDICES],X_val)
          rm(X_train_temp)
        }
      }
    }

    #Do predictions
    if(strtoi(args[12])==0){
      predictions <-predict_class_LR_RHS_validation(ourModel.onevEach$Samples,X_val)
    }else{
      predictions<- ourModel.onevEach$validationDataPredictions
    }

    all_preds[i,] <- predictions

    #Store the results to data frame
    DF <-data.frame(One=predictions, Others=1-predictions, ActualClass= validationClasses, PredictedClass=ifelse(predictions > 0.5,"One","Others"))

    iter[[i]] <- DF
    
  }
  iter_4classes[[J]] <- iter
  all_preds_4classes[[J]] <- all_preds

}

names(iter_4classes) <- CLASSLIST_V

print("Calculate AUCs and PRAUCs")

AUCs <- list()
for(j in 1:length(CLASSLIST_V)){
  AUCs[[j]] <-calculate_AUROC_validation(iter_4classes[[j]],CLASSLIST_V[j])
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

  AUC.medians.LR_RHS <- rep(0,N_classes)
  AUC.IDs <- rep(0,N_classes)
  AUPRC.medians.LR_RHS <- rep(0,N_classes)

  AUC.25q.LR_RHS <- rep(0,N_classes)
  AUPRC.25q.LR_RHS <- rep(0,N_classes)

  AUC.75q.LR_RHS <- rep(0,N_classes)
  AUPRC.75q.LR_RHS <- rep(0,N_classes)

  for(i in 1:length(CLASSLIST_V)){
    AUC.medians.LR_RHS[i] <- median(AUC_Bound$AUC[AUC_Bound$ID==CLASSLIST_V[i]])

    AUPRC.medians.LR_RHS[i] <- median(PRAUC_Bound$AUC[PRAUC_Bound$ID==CLASSLIST_V[i]])

    AUC.25q.LR_RHS[i] <- quantile(AUC_Bound$AUC[AUC_Bound$ID==CLASSLIST_V[i]],0.25)

    AUPRC.25q.LR_RHS[i] <- quantile(PRAUC_Bound$AUC[PRAUC_Bound$ID==CLASSLIST_V[i]],0.25)

    AUC.75q.LR_RHS[i] <- quantile(AUC_Bound$AUC[AUC_Bound$ID==CLASSLIST_V[i]],0.75)

    AUPRC.75q.LR_RHS[i] <- quantile(PRAUC_Bound$AUC[PRAUC_Bound$ID==CLASSLIST_V[i]],0.75)

    AUC.IDs[i] <- CLASSLIST[i]
  }


  AUC.median.df <- data.frame(
    AUC_median=AUC.medians.LR_RHS,
    AUPRC_median=AUPRC.medians.LR_RHS,
    AUC_25q=AUC.25q.LR_RHS,
    AUPRC_25q=AUPRC.25q.LR_RHS,
    AUC_75q=AUC.75q.LR_RHS,
    AUPRC_75q=AUPRC.75q.LR_RHS,
    classname=CLASSLIST)

  save(AUC.median.df, file = args[11],compress="xz")

}
