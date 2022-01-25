#Note that files OnevAllClassifiers.R and AUC_calculation_methods.R  must be in the same folder as this script (or whole path should be defined)

#OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence

#Arguments to the script
args <- commandArgs(TRUE)
#1 File path and name template where fitted Stan models are stored
#2 Filename and path for data splits file
#3 Filename and path for the thinned data object
#4 Filename into which to store the AUC plot for our model, with whole path
#5 Filename into which to store the PRAUC plot for our model, with whole path
#6 save AUC boxplots Note: the code for making the plots was removed for clarity, these figures were not used in the manuscript.
#7 save AUC and AUPRC values into a file
#8 AUC file name (if 10==0 this is not used)
#9 thinned validation data object
#10 feature list TOP
#11 feature list BOTTOM
#12 Path where to write the ROC plots with averaged predictions (over data splits) Note: the code for making the plots was removed for clarity, these figures were not used in the manuscript. The code for the ROC plots presented in the paper is in a separate script.
#13 file name of the whole validation data object
#14 file name id

#Test that the number of input arguments is correct
if (length(args)!=14) {
    stop("The number of input arguments is incorrect.", call.=FALSE)
}

source("OnevAllClassifiers.R")
source("AUC_calculation_methods.R")

prepare_DMR_counts <- function(WD,F_top,F_bottom){

  X_top <- as.matrix(WD[rownames(WD) %in% F_top,])
  X_bottom <- as.matrix(WD[rownames(WD) %in% F_bottom,])
 
  #calculating the count of DMRs with non-zero counts
  X_top <- X_top > 0
  X_bottom <- X_bottom > 0
 
  X_top <-as.matrix(colSums(X_top),ncol=1)
  X_bottom <-as.matrix(colSums(X_bottom),ncol=1) 
  X <- cbind(X_top,X_bottom)
  return(X)
}



load(args[13])
validationClasses <- validationData$classes
#Removed for saving space
rm(validationData) 


load(args[2])
load(args[3])

wholeData_thinned_training <- wholeData_thinned
rm(wholeData_thinned)

load(args[9])

wholeData_thinned_validation <- wholeData_thinned 
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

#Go over each class in validation data
for(J in 1:length(CLASSLIST)){
  print(paste("Class ", J,sep=""))
  j <- CLASSLIST_num[J] 

  all_preds <- matrix(nrow=N_SPLITS,ncol=ncol(wholeData_thinned_validation))
  iter<-list()

  #Go over data splits
  for(i in 1:N_SPLITS){ #placeholder loop
    print(paste("Data split ", i,sep=""))
    INDICES <- dataSplits$samples[[i]]

    #Load model and test set results
    load(paste(args[1],"_ID",i,"_CLASS",j,".RData",sep=""))
    N_features <- ncol(ourModel.onevEach$Samples$beta)

    #prepare validation data for DMRcount model.
    #Load top features
    load(paste(args[10],i,".RData",sep=""))
    #Load bottom features
    load(paste(args[11],i,".RData",sep=""))

    Features_top <- FeatureList_top[[j]]
    Features_bottom <- FeatureList_bottom[[j]]

    X_train <- prepare_DMR_counts(wholeData_thinned_training[,INDICES],Features_top,Features_bottom)
    X_val <- prepare_DMR_counts(wholeData_thinned_validation,Features_top,Features_bottom)

    X_val <- normalizecounts_scale_DMRcounts(wholeData_thinned_training,wholeData_thinned_validation,X_val)
    X_val <- standardizecounts_validation(t(X_train),t(X_val),scaling=0.5)
    rm(X_train)

    predictions <- predict_class_LR(ourModel.onevEach$Samples,X_val)

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
save(ROC_list, file = paste(args[12],"/data_for_ROC_validation_",args[14],".RData",sep=""),compress="xz")



AUC_Bound <- rbind(AUCs[[1]],AUCs[[2]],AUCs[[3]],AUCs[[4]])
PRAUC_Bound <- rbind(PRAUCs[[1]],PRAUCs[[2]],PRAUCs[[3]],PRAUCs[[4]])


print("Save AUC and PRAUC values into a file")

N_classes <- length(CLASSLIST_V)
if(strtoi(args[7])==1){

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


    AUC.IDs[i] <- CLASSLIST_V[i]
  }


  AUC.median.df <- data.frame(
    AUC_median=c(AUC.medians.LR_RHS),
    AUPRC_median=c(AUPRC.medians.LR_RHS),
    AUC_25q=c(AUC.25q.LR_RHS),
    AUPRC_25q=c(AUPRC.25q.LR_RHS),
    AUC_75q=c(AUC.75q.LR_RHS),
    AUPRC_75q=c(AUPRC.75q.LR_RHS),
    method=rep(c("ourMethod"),each=length(CLASSLIST_V)),
    classname=CLASSLIST_V)

  save(AUC.median.df, file = args[8],compress="xz")

}
