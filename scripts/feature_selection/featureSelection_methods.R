#Methods for DMR finding and dimension reduction


library(boot) #needed for inverse-logit calculation
library(dplyr)
library(ggplot2)
library(reshape2)
library(tidyr)
library(broom)
library(caret)
library(limma)
library(glmnet)
library(NMF)
library(doParallel)
library(pROC)
library(stats)

source("modelTraining_methods.R") #Data normalization methods etc. are shared

#In the functions PCA_allWindows, PCA_onlyDMRs and ISPCA_allWindows the training data set up is based on the  OnevsEach function (from OnevAllClassifier.R file). OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence

#Instead of moderated t-test/Fisher's exact test, do PCA for using the found components as features in classification
PCA_allWindows <- function(Mat, Indices, transform=0){
  #The zero rows should be already removed from the input data. They should also be removed before doing predictions to the test data set.
  #BUT it is possible, that there are zero rows after picking training samples. Such rows must be removed. Then they should also be removed from test data before prediction.

  TrainData <- Mat[,Indices]
 
  #Remove genomic windows with zero counts for all samples (will cause PCA to fail)
  TrainData <- TrainData[rowSums(TrainData)>0,]

  #Do transformation to the data
  if(transform==1){
    TrainData <- log2(TrainData * 0.3 + 1e-6)
  }

  pca.results <- prcomp(t(TrainData), center=TRUE, scale = TRUE)  

  return(pca.results)
  #The pca.results object can then be saved. It contains the information for scaling, centering and transforming the test data.

}

#Perform PCA on the data, but use only DMR windows as input
PCA_onlyDMRs <- function(Mat, Indices, FeatureList, class, transform=0){

  #The zero rows should be already removed from the input data. They should also be removed before doing predictions to the test data set.
  #BUT it is possible, that the zero rows after picking training samples must be removed. Then they should also be removed from test data before prediction!!!

  TrainData <- Mat[,Indices]

  #If a DMR object is given as input, only the DMR rows will be picked from the data matrix
  if (!is.null(FeatureList)){
    Features <- FeatureList[[class]]
    TrainData <- TrainData[rownames(TrainData) %in% Features,]
  }

  #Remove genomic windows with zero counts for all samples (will cause PCA to fail)
  TrainData <- TrainData[rowSums(TrainData)>0,]

  #Do transformation to the data
  if(transform==1){
    TrainData <- log2(TrainData * 0.3 + 1e-6)
  }

  pca.results <- prcomp(t(TrainData), center=TRUE, scale = TRUE)  

  return(pca.results)
  #The pca.results object contains the information for scaling, centering and transforming the test data.

}

#Perform ISPCA on the data. The features to be used as input can be specifies or all windows can be used
ISPCA_allWindows <- function(Mat,classes.df, Indices, classLabels, FeatureList=NULL, class, transform=0, NC=NULL, NORMALIZE=FALSE, binarize=0){
  #FeatureList can be NULL if one does not want to specify which features to use for ISPCA (e.g. DMRs)
  #If FeatureList is NULL (and binarize is 0), class can set to be anything, as it will not be used
  #NORMALIZE: "Whether to scale the extracted features so that they all have standard deviation of one." from ISPCA help
  #binarize: should the clasit will not be used. The class which will have class label "1" should be defined with class. Labels of the other classes will be set to 0.

  TrainData <- Mat[,Indices]
  TrainPheno <- classes.df[Indices,]

  #If a DMR object is given as input, only the DMR rows will be picked from the data matrix
  if (!is.null(FeatureList)){
    Features <- FeatureList[[class]]
    TrainData <- TrainData[rownames(TrainData) %in% Features,]
  }

  #Data transformation
  if(transform==1){
    TrainData <- log2(TrainData * 0.3 + 0.5)
  }

  library(dimreduce)

  if(binarize==1){
    AllClasses.v <- unique(classes.df$Classes)
    CLASS_LABELS <- ifelse(TrainPheno$Classes == AllClasses.v[class],1,0)
  }else{
    CLASS_LABELS <- as.factor(TrainPheno$Classes) 
  }

  pca.results <- ispca(t(TrainData), CLASS_LABELS, nctot=NC, normalize = NORMALIZE)

  return(pca.results)
  #The pca.results object can then be saved. It contains the information for scaling, centering and transforming the test data.

}

#This is the DMR finding part from OnevsEach function (from OnevAllClassifier.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence) 
#This function has been modified to
#-discard DMRs for which the counts for all the samples is 0 (so there is no actual difference between the classes). This is done before picking DMRs based on the p-values.
#-save top and bottom DMRs into their own files for DMR count model usage
#-Use Fisher's test instead of moderated t-statistic from limma
#NOTE THAT THIS FUNCTION REQUIRES COUNT DATA. No transformations, scaling, normalization etc. should be applied before this!
DMR_finding_Fisher <- function(Mat, classes.df, Indices, nDMR){

  TrainData <- Mat[,Indices]
  TrainPheno <- classes.df[Indices,]

  print("The number of rows in TrainData before removing zero count rows")
  print(nrow(TrainData))

  TrainData <- TrainData[rowSums(TrainData)>0,]

  print("The number of rows in TrainData after removing zero count rows")
  print(nrow(TrainData))

  AllClasses.v <- unique(classes.df$Classes)

  FeatureList <- list()
  FeatureList_top <- list()
  FeatureList_bottom <- list()

  for(i in 1:length(AllClasses.v)) {

    FixedClass <- which(TrainPheno$Classes == AllClasses.v[[i]])
    OtherClasses <- which(!TrainPheno$Classes == AllClasses.v[[i]])


      DMRList <- list()
      DMRList_top <- list() #List where the top of the limma result list (top DMRs) are stored
      DMRList_bottom <- list() #List where the bottom of the limma result list (bottom DMRs) are stored
      OtherClasses.vector <- unique(TrainPheno$Classes[OtherClasses])
      print(OtherClasses.vector)
    ##This loop does DMR preselection using a one vs each criterion
    for(j in 1:length(OtherClasses.vector)) {

      CurrentOtherClass <- which(TrainPheno$Classes == OtherClasses.vector[[j]] )

      FixedClass.matrix <- TrainData[,FixedClass]
      OtherMatrix <- TrainData[,CurrentOtherClass]
      DMR.classes <- c(rep("One",ncol(FixedClass.matrix)), rep("Others",ncol(OtherMatrix)))
      DMR.Data <- cbind(FixedClass.matrix, OtherMatrix)

      #There is no reason to conduct the test if the count is zero for all samples for these classes
      zero_count_rows <- which(rowSums(DMR.Data)==0)
      DMR.Data <- DMR.Data[-zero_count_rows,]

      #Initialize matrix for storing Fisher's exact test results. The first column is for storing
      #the p-value and the second is for storing the odds-ratio for determining the hypo/hypermethylation status
      fisher_results <- matrix(nrow=nrow(DMR.Data),ncol=2)

      for(k in 1:nrow(DMR.Data)){
          #Multiplication by 1 transforms logical values into integers
          nonzeros <- (DMR.Data[k,]>0)*1
          contingency_table <- matrix(c(sum(nonzeros[DMR.classes=="One"]),length(FixedClass)-sum(nonzeros[DMR.classes=="One"]),sum(nonzeros[DMR.classes=="Others"]),length(CurrentOtherClass)-sum(nonzeros[DMR.classes=="Others"])),ncol=2)

          fisher_test <- fisher.test(contingency_table, alternative="two.sided")
          fisher_results[k,1] <- fisher_test$p.value
          fisher_results[k,2] <- (contingency_table[1,1]/contingency_table[1,2])/(contingency_table[2,1]/contingency_table[2,2]) #this might be inf sometimes!!
      }


      rownames(fisher_results) <- rownames(DMR.Data)
      nDMR.b <- nDMR/2

      hypo <- fisher_results[which(fisher_results[,2]>1),]
      hyper <- fisher_results[which(fisher_results[,2]<=1),]

      hypo <- hypo[order(hypo[,1]),]
      hyper <- hyper[order(hyper[,1]),]

      Features <- rbind(hypo[1:nDMR.b,],hyper[1:nDMR.b,])
      Features_top <- hyper[1:nDMR.b,]
      Features_bottom <- hypo[1:nDMR.b,]

      DMRList[[j]] <- rownames(Features)
      DMRList_top[[j]] <- rownames(Features_top)
      DMRList_bottom[[j]] <- rownames(Features_bottom)

      message(paste0(j,"of each vs other classes DMR selection done"))
    }

    #This creates feature set
    Features <- unlist(DMRList)
    FeatureList[[i]] <- Features

    Features_top <- unlist(DMRList_top)
    FeatureList_top[[i]] <- Features_top

    Features_bottom <- unlist(DMRList_bottom)
    FeatureList_bottom[[i]] <- Features_bottom

    }


    names(FeatureList) <- AllClasses.v
    names(FeatureList_top) <- AllClasses.v
    names(FeatureList_bottom) <- AllClasses.v
    FLists <- list(standard = FeatureList, top = FeatureList_top, bottom = FeatureList_bottom)
    return(FLists)

}

#This is the DMR finding part from OnevsEach function (from OnevAllClassifier.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence) with modifications to
#-discard DMRs for which the counts for all the samples is 0 (so there is no actual difference between the classes). This is done AFTER finding the DMRs
#-save top and bottom DMRs into their own files for DMR count model usage
DMR_finding_modifiedT_noZeroCounts <- function(Mat, classes.df, Indices, nDMR, newTransformation=0){
#newTransformation: old or new transformation. old = log2(x*0.3+1e-6) new = log2(x*0.3+0.5)

  TrainData <- Mat[,Indices]
  TrainPheno <- classes.df[Indices,]

  print("The number of rows in TrainData before removing zero count rows")
  print(nrow(TrainData))

  TrainData <- TrainData[rowSums(TrainData)>0,]

  print("The number of rows in TrainData after removing zero count rows")
  print(nrow(TrainData))

  if(newTransformation==0){
    TrainData <- log2(TrainData * 0.3 + 1e-6)
  }else{
    TrainData <- log2(TrainData * 0.3 + 0.5)
  }



  AllClasses.v <- unique(classes.df$Classes)

  FeatureList <- list()
  FeatureList_top <- list()
  FeatureList_bottom <- list()

  for(i in 1:length(AllClasses.v)) {

    FixedClass <- which(TrainPheno$Classes == AllClasses.v[[i]])
    OtherClasses <- which(!TrainPheno$Classes == AllClasses.v[[i]])


      DMRList <- list()
      DMRList_top <- list() #List into which the top of the limma result list are stored
      DMRList_bottom <- list() #List into which the bottom of the limma result list are stored
      OtherClasses.vector <- unique(TrainPheno$Classes[OtherClasses])
      print(OtherClasses.vector)
    #This loop does DMR preselection using a one vs each criterion
    for(j in 1:length(OtherClasses.vector)) {

      CurrentOtherClass <- which(TrainPheno$Classes == OtherClasses.vector[[j]] )

      FixedClass.matrix <- TrainData[,FixedClass]
      OtherMatrix <- TrainData[,CurrentOtherClass]
      DMR.classes <- c(rep("One",ncol(FixedClass.matrix)), rep("Others",ncol(OtherMatrix)))

      DMR.Data <- cbind(FixedClass.matrix, OtherMatrix)
      Des <- model.matrix(~0 + DMR.classes)
      colnames(Des) <- levels(factor(DMR.classes))
      LimmaFit <- lmFit(DMR.Data, Des)%>%
        contrasts.fit(., makeContrasts(One-Others, levels = Des))%>%
        eBayes(., trend = TRUE)%>%
        topTable(., number = nrow(FixedClass.matrix))

      LimmaFit <- LimmaFit%>%.[order(.$t),]

      nDMR.b <- nDMR/2

      TotalRows <- nrow(LimmaFit) - (nDMR.b + 1)
      Features <- rbind(LimmaFit[1:nDMR.b,] ,
                        LimmaFit[TotalRows:nrow(LimmaFit),])
      Features_top <-LimmaFit[1:nDMR.b,]
      Features_bottom <-LimmaFit[TotalRows:nrow(LimmaFit),]

      Features <- rownames(Features)

      Features_top <- rownames(Features_top)
      Features_bottom <- rownames(Features_bottom)

      DMRList[[j]] <- Features
      DMRList_top[[j]] <- Features_top
      DMRList_bottom[[j]] <- Features_bottom

      message(paste0(j,"of each vs other classes DMR selection done"))
    }

    Features <- unlist(DMRList)
    FeatureList[[i]] <- Features

    Features_top <- unlist(DMRList_top)
    FeatureList_top[[i]] <- Features_top

    Features_bottom <- unlist(DMRList_bottom)
    FeatureList_bottom[[i]] <- Features_bottom

    }


    names(FeatureList) <- AllClasses.v
    names(FeatureList_top) <- AllClasses.v
    names(FeatureList_bottom) <- AllClasses.v
    FLists <- list(standard = FeatureList, top = FeatureList_top, bottom = FeatureList_bottom)
    return(FLists)

}




