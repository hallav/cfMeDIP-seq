#Methods for AUROC and AUPRC calculation

library(dplyr)
library(reshape2)
library(tidyr)
library(broom)
library(caret)
library(pROC)
library(stats)

#This function is from file MachineLearning_Final.html from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
PredFunction <- function(ModelList, TestData, Indices, classes.df) { 
  
  TrainPheno <- classes.df[Indices,]
  TestData <- TestData[,!colnames(TestData) %in% TrainPheno$ID]
  TestPheno <- classes.df%>%filter(!ID %in% TrainPheno$ID)

  
  Predictions.list <- list()
  OutputNames <- names(ModelList)
  
  for(i in 1:length(ModelList)) {
  
    Features <- ModelList[[i]]$Model$finalModel$xNames
    TestDataNew <- TestData[match(Features,rownames(TestData)),]
    Model <- ModelList[[i]]$Model
    Prediction.classProbs <- predict(Model, newdata = t(TestDataNew), type = "prob")%>%
      data.frame
    
    Prediction.classProbs$ActualClass <- TestPheno$Classes
    Prediction.classProbs$PredictedClass <- predict(Model, newdata = t(TestDataNew), type = "raw")
    
    Predictions.list[[i]] <- Prediction.classProbs
message(i)
}

 names(Predictions.list) <- OutputNames
 return(Predictions.list)
 
} 


#Function for validation cohort AUC calculation. Modified fundtion GetAUC.ClassWise2 from OnevAllClassifiers.R to make calculations only for one class in the validation cohort. OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
calculate_AUROC_validation <- function(modelPredictions, CLASSNAME) {

oneClassPredictions <- lapply(modelPredictions, function(x) x%>%mutate(Class2 = ifelse(ActualClass == CLASSNAME,"One","Others")))
auc <- lapply(oneClassPredictions, function(x) with(x,roc(Class2 ~ One)$auc))

auc_DF <- data.frame(AUC = unlist(auc))%>%
    mutate(ID = CLASSNAME)

return(auc_DF)

}


#Modified function GetAUC.ClassWise2 from OnevAllClassifiers.R to make a function for AUPRC calculation for discovery cohort classes. OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
calculate_AUPRC_discovery<- function(modelPredictions) {

  print("Start PRAUC calculation")
  library(PRROC)

  print("Class: Normal")
  Normals <- lapply(modelPredictions, function(x) x$Control)
  Normals.predictions <- lapply(Normals, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "Control","One","Others")))
  Normals.auc <- lapply(Normals.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: PDAC")
  PDACs <- lapply(modelPredictions, function(x) x$PDAC)
  PDACs.predictions <- lapply(PDACs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "PDAC","One","Others")))
  PDACs.auc <- lapply(PDACs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: BRCA")
  BRCAs <- lapply(modelPredictions, function(x) x$BRCA)
  BRCAs.predictions <- lapply(BRCAs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "BRCA","One","Others")))
  BRCAs.auc <- lapply(BRCAs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: BLCA")
  BLCAs <- lapply(modelPredictions, function(x) x$BL)
  BLCAs.predictions <- lapply(BLCAs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "BL","One","Others")))
  BLCAs.auc <- lapply(BLCAs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: LUC")
  LUCs <- lapply(modelPredictions, function(x) x$Lung)
  LUCs.predictions <- lapply(LUCs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "Lung","One","Others")))
  LUCs.auc <- lapply(LUCs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: AML")
  AMLs <- lapply(modelPredictions, function(x) x$AML)
  AMLs.predictions <- lapply(AMLs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "AML","One","Others")))
  AMLs.auc <- lapply(AMLs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: CRC")
  CRCs <- lapply(modelPredictions, function(x) x$CRC)
  CRCs.predictions <- lapply(CRCs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "CRC","One","Others")))
  CRCs.auc <- lapply(CRCs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Class: RCC")
  RCCs <- lapply(modelPredictions, function(x) x$RCC)
  RCCs.predictions <- lapply(RCCs, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "RCC","One","Others")))
  RCCs.auc <- lapply(RCCs.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  print("Make data frames")

  AMLs.auc <- data.frame(AUC = unlist(AMLs.auc))%>%
    mutate(ID = "AML")

  BLCAs.auc <- data.frame(AUC = unlist(BLCAs.auc))%>%
    mutate(ID = "BLCA")

  BRCAs.auc <- data.frame(AUC = unlist(BRCAs.auc))%>%
    mutate(ID = "BRCA")

  CRCs.auc <- data.frame(AUC = unlist(CRCs.auc))%>%
    mutate(ID = "CRC")

  LUCs.auc <- data.frame(AUC = unlist(LUCs.auc))%>%
    mutate(ID = "LUC")

  Normals.auc <- data.frame(AUC = unlist(Normals.auc))%>%
    mutate(ID = "Normal")

  PDACs.auc <- data.frame(AUC = unlist(PDACs.auc))%>%
    mutate(ID = "PDAC")

  RCCs.auc <- data.frame(AUC = unlist(RCCs.auc))%>%
    mutate(ID = "RCC")

  print("Bind dataframes")
  AUC_DF_allClasses <- rbind(AMLs.auc,BLCAs.auc,BRCAs.auc,CRCs.auc,LUCs.auc,Normals.auc,PDACs.auc,RCCs.auc)


  return(AUC_DF_allClasses)

}

#Function for validation cohort AUPRC calculation. Modified fundtion GetAUC.ClassWise2 from OnevAllClassifiers.R to make precision-recall calculations only for one class in the validation cohort. OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
calculate_AUPRC_validation <- function(modelPredictions, CLASSNAME) {

  print(paste("Start PRAUC calculation for class ",CLASSNAME,sep=""))
  library(PRROC)

  oneClassPredictions <- lapply(modelPredictions, function(x) x%>%mutate(Class2 = ifelse(ActualClass == CLASSNAME,"One","Others")))
  auc <- lapply(oneClassPredictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  auc_DF <- data.frame(AUC = unlist(auc))%>%
    mutate(ID = CLASSNAME)
 
  return(auc_DF)

}


#Adapted function calculate_AUPRC_discovery for intracranial tumors data set
GetAUPRC.ClassWise.braindata <- function(Runs) {
  library(PRROC) 
  
  BM <- lapply(Runs, function(x) x$BrainMets)
  BM.predictions <- lapply(BM, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "BrainMets","One","Others")))
  BM.auc <- lapply(BM.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))
 
  HPC <- lapply(Runs, function(x) x$Hemangiopericytoma)
  HPC.predictions <- lapply(HPC, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "Hemangiopericytoma","One","Others")))
  HPC.auc <- lapply(HPC.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  MG <- lapply(Runs, function(x) x$Meningioma)
  MG.predictions <- lapply(MG, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "Meningioma","One","Others")))
  MG.auc <- lapply(MG.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  NE <- lapply(Runs, function(x) x$NE)
  NE.predictions <- lapply(NE, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "NE","One","Others")))
  NE.auc <- lapply(NE.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  WTG <- lapply(Runs, function(x) x$WT.Glioma)
  WTG.predictions <- lapply(WTG, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "WT.Glioma","One","Others")))
  WTG.auc <- lapply(WTG.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  MUTG <- lapply(Runs, function(x) x$MUT.Glioma)
  MUTG.predictions <- lapply(MUTG, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "MUT.Glioma","One","Others")))
  MUTG.auc <- lapply(MUTG.predictions, function(x) with(x,pr.curve(scores.class0 = x$One[x$Class2=="One"], scores.class1 = x$One[x$Class2=="Others"], curve = T)$auc.integral))

  BM.auc <- data.frame(AUC = unlist(BM.auc))%>%
    mutate(ID = "BrainMets")
  HPC.auc <- data.frame(AUC = unlist(HPC.auc))%>%
    mutate(ID = "Hemangiopericytoma")
  MG.auc <- data.frame(AUC = unlist(MG.auc))%>%
    mutate(ID = "Meningioma")
  NE.auc <- data.frame(AUC = unlist(NE.auc))%>%
    mutate(ID = "NE")
  WTG.auc <- data.frame(AUC = unlist(WTG.auc))%>%
    mutate(ID = "WT.Glioma")  MUTG.auc <- data.frame(AUC = unlist(MUTG.auc))%>%
    mutate(ID = "MUT.Glioma")
  

  Bound <- rbind(BM.auc,HPC.auc,MG.auc,NE.auc,WTG.auc,MUTG.auc)

 
  return(Bound)
 
}
#Adapted AUC calculation function for intracranial tumors data set
GetAUC.ClassWise.braindata <- function(Runs) {
  
  
  BM <- lapply(Runs, function(x) x$BrainMets)
  BM.predictions <- lapply(BM, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "BrainMets","One","Others")))
  BM.auc <- lapply(BM.predictions, function(x) with(x,roc(Class2 ~ One)$auc))
 
  HPC <- lapply(Runs, function(x) x$Hemangiopericytoma)
  HPC.predictions <- lapply(HPC, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "Hemangiopericytoma","One","Others")))
  HPC.auc <- lapply(HPC.predictions, function(x) with(x,roc(Class2 ~ One)$auc))

  MG <- lapply(Runs, function(x) x$Meningioma)
  MG.predictions <- lapply(MG, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "Meningioma","One","Others")))
  MG.auc <- lapply(MG.predictions, function(x) with(x,roc(Class2 ~ One)$auc))

  NE <- lapply(Runs, function(x) x$NE)
  NE.predictions <- lapply(NE, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "NE","One","Others")))
  NE.auc <- lapply(NE.predictions, function(x) with(x,roc(Class2 ~ One)$auc))

  WTG <- lapply(Runs, function(x) x$WT.Glioma)
  WTG.predictions <- lapply(WTG, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "WT.Glioma","One","Others")))
  WTG.auc <- lapply(WTG.predictions, function(x) with(x,roc(Class2 ~ One)$auc))

  MUTG <- lapply(Runs, function(x) x$MUT.Glioma)
  MUTG.predictions <- lapply(MUTG, function(x) x%>%mutate(Class2 = ifelse(ActualClass == "MUT.Glioma","One","Others")))
  MUTG.auc <- lapply(MUTG.predictions, function(x) with(x,roc(Class2 ~ One)$auc))  

  BM.auc <- data.frame(AUC = unlist(BM.auc))%>%
    mutate(ID = "BrainMets")
  HPC.auc <- data.frame(AUC = unlist(HPC.auc))%>%
    mutate(ID = "Hemangiopericytoma")
  MG.auc <- data.frame(AUC = unlist(MG.auc))%>%
    mutate(ID = "Meningioma")
  NE.auc <- data.frame(AUC = unlist(NE.auc))%>%
    mutate(ID = "NE")
  WTG.auc <- data.frame(AUC = unlist(WTG.auc))%>%
    mutate(ID = "WT.Glioma")
  MUTG.auc <- data.frame(AUC = unlist(MUTG.auc))%>%
    mutate(ID = "MUT.Glioma")
  

  Bound <- rbind(BM.auc,HPC.auc,MG.auc,NE.auc,WTG.auc,MUTG.auc)

 
  return(Bound)
 
}

