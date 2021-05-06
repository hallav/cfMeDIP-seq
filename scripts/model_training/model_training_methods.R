#The function OnevsEach from OnevAllClassifiers.R file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence has been used as a bases for the following functions:
#train_GLMNet_model (modified version of OnevsEach function)
#train_LR_DMRcount_model (OnevsEach used as basis for defining the training and test data)
#train_LR_RHS_model_PCA_features (OnevsEach used as basis for defining the training and test data)
#train_LR_RHS_model (OnevsEach used as basis for defining the training and test data)

library(rstan)
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

rstan_options(auto_write = TRUE) #Run this line to avoid recompilation of unchanged Stan models

#Defining Stan model files

#Logistic regression with regularised HS, Stan model by Piironen & Vehtari (2017). Sparsity information and regularization in the horseshoe and other shrinkage priors. Electronic Journal of Statistics, 11(2), 5018-5051.
STAN_FILE_NAME_LR_RHS='logisticregression_regularized_HS.stan'

#Logistic regression with hypo- and hypoermethylated DMR counts as covariates. LR with recommended prior from Gelman et al.(2008). A weakly informative default prior distribution for logistic and other regression models. Annals of applied Statistics, 2(4), 1360-1383.
STAN_FILE_NAME_LR_DMR='logisticregression_DMRcounts.stan'


#This line is from MachineLearning_Final.html from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
Features.CVparam<- trainControl(method = "repeatedcv",number = 10, repeats=3,verboseIter=TRUE,returnData=FALSE,classProbs = TRUE,savePredictions=FALSE)


#Function to normalize count data SAMPLEWISE
normalizecounts <- function(datamatrix) {

    #datamatrix = the input data to be normalized. The rows correspond to the genomic locations and columns to samples.

    for(i in 1:ncol(datamatrix)){
        datamatrix[,i] <- datamatrix[,i]/sum(datamatrix[,i])
    }
    return(datamatrix)
}

#Function to normalize count data SAMPLEWISE + multiply with mean total read count for all samples for scaling
normalizecounts_scale <- function(datamatrix) {

    #datamatrix = the input data to be normalized. The rows correspond to the genomic locations and columns to samples.
    
    mean_total_counts <- mean(colSums(datamatrix))

    for(i in 1:ncol(datamatrix)){
        datamatrix[,i] <- datamatrix[,i]/sum(datamatrix[,i])
    }
    return(datamatrix*mean_total_counts)
}

normalizecounts_scale_DMRcounts <- function(datamatrix,datamatrix_picked,designmatrix) {

    #datamatrix = the input data based on which the normalization is done. The rows correspond to the genomic locations and columns to samples.
    #datamatrix_picked = the same as above but only the data for the picked samples
    #designmatrix = the Stan input matrix, which has two columns and the number of rows is the same as the number of samples 
    #ncol(datamatrix_picked) and nrow(designmatrix) should be matching!

    mean_total_counts <- mean(colSums(datamatrix))

    for(i in 1:ncol(datamatrix_picked)){
        designmatrix[i,] <- designmatrix[i,]/sum(datamatrix_picked[,i])
    }
    return(designmatrix*mean_total_counts)
}

#Function to standardize count data genomic window -wise (=covariatewise)
#Returns data with mean 0 and sd 1
standardizecounts <- function(datamatrix, scaling=1) {

    #datamatrix = the input data to be normalized. The rows correspond to the genomic locations and columns to samples.
    #scaling = the desired sd for the covariates (=locations) in the output datamatrix, default is 1. Value should be >0

    for(i in 1:nrow(datamatrix)){
        datamatrix[i,] <- ((datamatrix[i,]-mean(datamatrix[i,]))/sd(datamatrix[i,]))*scaling
    }
    return(datamatrix)
}

standardizecounts_scale_only <- function(datamatrix, scaling=1) {

    #datamatrix = the input data to be normalized. The rows correspond to the genomic locations and columns to samples.
    #scaling = the desired sd for the covariates (=locations) in the output datamatrix, default is 1. Value should be >0

    for(i in 1:nrow(datamatrix)){
        datamatrix[i,] <- (datamatrix[i,]/sd(datamatrix[i,]))*scaling
    }
    return(datamatrix)
}

Mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
}


standardizecounts_validation <- function(DM_training, DM_validation, scaling=1) {
  #DM_training = the training data based on which we do the standardization. 
  #The rows correspond to the genomic locations and columns to samples.
  #DM_validation = the input validation data to be standardized. The rows 
  #correspond to the genomic locations and columns to samples. DM_training 
  #and DM_validation should have the same number of rows.
  #scaling = the desired sd for the covariates (=locations) in the output 
  #DM_validation, default is 1. Value should be >0
  
  #Note that the order of normalization and standardization should be the same as for the training data!
  
  for(i in 1:nrow(DM_training)){
    DM_validation[i,] <- ((DM_validation[i,]-mean(DM_training[i,]))/sd(DM_training[i,]))*scaling
  }
  return(DM_validation)
}

standardizecounts_validation_scale_only <- function(DM_training, DM_validation, scaling=1) {
  #DM_training = the training data based on which we do the standardization.
  #The rows correspond to the genomic locations and columns to samples.
  #DM_validation = the input validation data to be standardized. The rows
  #correspond to the genomic locations and columns to samples. DM_training
  #and DM_validation should have the same number of rows.
  #scaling = the desired sd for the covariates (=locations) in the output
  #DM_validation, default is 1. Value should be >0

  #Note that the order of normalization and standardization should be the same as for the training data!

  for(i in 1:nrow(DM_training)){
    DM_validation[i,] <- (DM_validation[i,]/sd(DM_training[i,]))*scaling
  }
  return(DM_validation)
}

#Function to normalize count data SAMPLEWISE + multiply with mean total read count for all samples for scaling
normalizecounts_scale_validation <- function(DM_training,DM_validation) {

    #DM_validation = the input data to be normalized. The rows correspond to the genomic locations and columns to samples.
    #DM_training = the training data set is used for scaling the data in the same way as the training data was.

    mean_total_counts <- mean(colSums(DM_training))

    for(i in 1:ncol(DM_validation)){
        DM_validation[,i] <- DM_validation[,i]/sum(DM_validation[,i])
    }
    return(DM_validation*mean_total_counts)
}


#This is prediction function in the case that the alpha and beta samples are used for calculating the success rate for the bernoulli distribution
predict_class_LR <- function(extracted_samples,design_matrix) {
    #Input for the function
    #extracted samples: the fit object from the Stan run
    #design_matrix: design matrix for the new data points for which we want to do the predictions for (similar to X in the Stan run)

    #prediction is a matrix of shape n_samples x n_test_data_points
    prediction <- matrix(,nrow=length(extracted_samples$alpha),ncol=ncol(design_matrix))

    for(i in 1:ncol(design_matrix)){
        for(j in 1:length(extracted_samples$alpha)){
            prediction[j,i] <- inv.logit(extracted_samples$alpha[j]+ t(extracted_samples$beta[j,]) %*% design_matrix[,i])
        }
    }
  
    return(colMeans(prediction))

}

#This is prediction function in the case that the beta0 and beta samples are used for calculating the success rate for the bernoulli distribution
#For logistic regression with regularised HS prior
predict_class_LR_RHS <- function(extracted_samples,design_matrix) {
    #Input for the function
    #extracted samples: the fit object from the Stan run
    #design_matrix: design matrix for the new data points for which we want to do the predictions for (similar to X in the Stan run)

    #prediction is a matrix of shape n_samples x n_test_data_points
    prediction <- matrix(,nrow=length(extracted_samples$beta0),ncol=ncol(design_matrix))

    for(i in 1:ncol(design_matrix)){
        for(j in 1:length(extracted_samples$beta0)){
            prediction[j,i] <- inv.logit(extracted_samples$beta0[j]+ t(extracted_samples$beta[j,]) %*% design_matrix[,i])
        }
    }
  
    return(colMeans(prediction))

}

#The same thing as above, but takes into account that the beta0 has been renamed alpha when the samples were stored
predict_class_LR_RHS_validation <- function(extracted_samples,design_matrix) {
    #Input for the function
    #extracted samples: the fit object from the Stan run
    #design_matrix: design matrix for the new data points for which we want to do the predictions for (similar to X in the Stan run)

    #prediction is a matrix of shape n_samples x n_test_data_points
    prediction <- matrix(,nrow=length(extracted_samples$alpha),ncol=ncol(design_matrix))

    for(i in 1:ncol(design_matrix)){
        for(j in 1:length(extracted_samples$alpha)){
            prediction[j,i] <- inv.logit(extracted_samples$alpha[j]+ t(extracted_samples$beta[j,]) %*% design_matrix[,i])
        }
    }

    return(colMeans(prediction))

}



#Return a fata frame with alpha and beta means
return_fitted_parameters <- function(extracted_samples) {

    
    fitted_parameters <- data.frame(alpha = mean(extracted_samples$alpha), beta = colMeans(extracted_samples$beta))

    return(fitted_parameters)

}

#Same as above but returns the fitted parameters as a list instead of a data frame
return_fitted_parameters_list <- function(extracted_samples) {

    fitted_parameters <- list(alpha = mean(extracted_samples$alpha),beta = colMeans(extracted_samples$beta))

    return(fitted_parameters)

}


#Function for regularised HS prior, which uses different names for the variables
return_fitted_parameters_list_RHS <- function(extracted_samples) {


    fitted_parameters <- list(alpha = mean(extracted_samples$beta0),beta = colMeans(extracted_samples$beta))

    return(fitted_parameters)

}



#Modified the OnevsEach function from OnevAllClassifier.R file to only contain the model training part, DMR finding is done separately
train_GLMNet_model <- function(Mat, classes.df, Indices, FeatureList) {

  TrainData <- Mat[,Indices]
  TrainPheno <- classes.df[Indices,]
  
  TestData <- Mat[,!colnames(Mat) %in% TrainPheno$ID]
  TestPheno <- classes.df%>%filter(!ID %in% TrainPheno$ID)
  
  AllClasses.v <- unique(classes.df$Classes)  
  ModList <- list()
  
  for(i in 1:length(AllClasses.v)) {

    Features <- FeatureList[[i]]


    NewAnn <- ifelse(TrainPheno$Classes == AllClasses.v[[i]],"One","Others")

    Model <- train(x = t(TrainData[rownames(TrainData) %in% Features,]), y = factor(NewAnn), trControl = Features.CVparam, method = "glmnet" , tuneGrid = expand.grid(.alpha=c(0,0.2,0.5,0.8,1),.lambda = seq(0,0.05,by=0.01)), metric = "Kappa")
    message("Model Selection Complete")
    Prediction.classProbs <- predict(Model, newdata = t(TestData), type = "prob")%>%
      data.frame
    
    Prediction.classProbs$ActualClass <- TestPheno$Classes
    Prediction.classProbs$PredictedClass <- predict(Model, newdata = t(TestData), type = "raw")

    CombinedOutput <- list(Model = Model, TestPred = Prediction.classProbs)
    ModList[[i]] <- CombinedOutput

  }

  names(ModList) <- AllClasses.v  
  return(ModList)  

}





#Function for fitting logistic regression with hypo- and hypermethylated DMR counts as the two covariates in the model
#NOTE: the data should be in non-transformed and non-scaled form when given as input. 
train_LR_DMRcount_model <- function(DM, classInformation, TrainIndices, FeatureList_top,FeatureList_bottom,index,testSetPrediction=1) {
#DM: discovery cohort data object 
#classInformation: sample phenotypes
#TrainIndices: training set indices
#FeatureList_top: list of DMRs
#FeatureList_bottom: list of DMRs
#index: class for which the classifier is trained (one vs. other classes)
#testSetPrediction: make predictions for the test set


  TrainData <- DM[,TrainIndices]
  TrainPheno <- classInformation[TrainIndices,]

  if(testSetPrediction==1){
    TestData <- DM[,!colnames(DM) %in% TrainPheno$ID]
    TestPheno <- classInformation%>%filter(!ID %in% TrainPheno$ID)
  }

  AllClasses.v <- unique(classInformation$Classes)
  ModList <- list()

  i=index

  Features_top <- FeatureList_top[[i]]
  Features_bottom <- FeatureList_bottom[[i]]

  NewAnn <- ifelse(TrainPheno$Classes == AllClasses.v[[i]],"One","Others")

  X_top <- as.matrix(TrainData[rownames(TrainData) %in% Features_top,])
  X_bottom <- as.matrix(TrainData[rownames(TrainData) %in% Features_bottom,])

  #calculating the count of DMRs with non-zero counts

  X_top <- X_top > 0
  X_bottom <- X_bottom > 0

  X_top <-as.matrix(colSums(X_top),ncol=1)
  X_bottom <-as.matrix(colSums(X_bottom),ncol=1)

  X <- cbind(X_top,X_bottom)

  #Normalization and standardization

  X <- normalizecounts_scale_DMRcounts(DM,TrainData,X)
  X <- t(standardizecounts(t(X),scaling=0.5))

  SCALE_ICEPT<-10
  SCALE_COEFF<-2.5

  stan_input <- list(n=ncol(TrainData),x=X, y=ifelse(factor(NewAnn)=="One",1,0),scale_icept=SCALE_ICEPT,scale_coeff=SCALE_COEFF)

  SM <- stan_model(STAN_FILE_NAME_LR_DMR)

  fit <- sampling(SM, data = stan_input, seed=123, iter= 3500, control = list(adapt_delta=0.9))

  print(fit)
  warnings()


  la <- rstan::extract(fit, permuted = TRUE)

  #Predictions for test set samples
  if(testSetPrediction==1){
    X_test_top <- as.matrix(TestData[rownames(TestData) %in% Features_top,])
    X_test_bottom <- as.matrix(TestData[rownames(TestData) %in% Features_bottom,])
    X_test_top <- X_test_top > 0
    X_test_bottom <- X_test_bottom > 0

    X_test_top <-as.matrix(colSums(X_test_top),ncol=1)
    X_test_bottom <-as.matrix(colSums(X_test_bottom),ncol=1)

    X_test <- cbind(X_test_top,X_test_bottom)

    #Normalization and standardization

    X_test <- normalizecounts_scale_DMRcounts(DM,TestData,X_test)
    X_train_temp <- normalizecounts_scale_DMRcounts(DM,TrainData,cbind(X_top,X_bottom))
    X_test <- t(standardizecounts_validation(t(X_train_temp), t(X_test), scaling=0.5))

    predictions_test <-predict_class_LR(la,t(X_test))

    testDataResults <- data.frame(trueClass = ifelse(TestPheno$Classes == AllClasses.v[[i]],1,0), trueClassName = TestPheno$Classes, predictedClass = predictions_test)
  } else {
    #If testSetPrediction=0 an empty data frame is stored
    testDataResults <- data.frame(TrueClass = integer(), trueClassName = character(), predictedClass = integer())
  }
  
  samples <- list(alpha=la$alpha, beta=la$beta)
  CombinedOutput_LR <- list(FittedModel = return_fitted_parameters_list(la), testDataResults = testDataResults, Samples = samples)

  return(CombinedOutput_LR)

}

train_LR_RHS_model_PCA_features <- function(DM, classInformation, TrainIndices, index, testSetPrediction=1, parameter_P0=300, pca_results, N_components=10,pairsPlot=0,FigFolder,dataSplitID,ISPCA=0,normalize_pca=0) {
#DM: discovery cohort data object
#classInformation: sample phenotypes
#TrainIndices: training set indices
#index: class for which the classifyer is trained (one vs. other classes)
#testSetPrediction: make predictions for the test set
#parameter_P0: parameter for the RHS prior, how many non-zero coefficients are expected in the model
#pca_results: result object from prcomp function
#N_components: number of components to be used as features in the logistic regression 
#pairsPlot: plot Stan diagnostics plot
#FigFolder: a folder where plots are saved, define if pairsPlot=1
#dataSplitID: used for saving the plots
#ISPCA: are results from ISPCA (1)  used instead of PCA (0)
#normalize_pca: standardize the data before LR. Use only for basic PCA, for ISPCA use normalize=TRUE when calling ispca function

  if(ISPCA==1){
    library(dimreduce)
  }

  #before running this function: remove zero-rows from DM

  TrainData <- DM[,TrainIndices]
  TrainPheno <- classInformation[TrainIndices,]
  X <- t(predict(pca_results, t(TrainData)))

  if(N_components>length(X[,1])){

    print(paste("N_components=",N_components, " was higher than length(X[,1])=",length(X[,1]), ". Setting N_components=", length(X[,1]),sep=""))
    N_components=length(X[,1])
  }

  X <- as.matrix(X[1:N_components,])


  if (normalize_pca==1){
    print("Normalizing training data")
    X <- standardizecounts_scale_only(X)

  }


  if(testSetPrediction==1){
    X_test <- DM[,!colnames(DM) %in% TrainPheno$ID]
    TestPheno <- classInformation%>%filter(!ID %in% TrainPheno$ID)

    X_test <- t(predict(pca_results, t(X_test)))
    X_test <- as.matrix(X_test[1:N_components,])


    if (normalize_pca==1){
      print("Normalizing test data")
      X_train_temp = t(as.matrix(predict(pca_results, t(TrainData))))

      X_test <- standardizecounts_validation_scale_only(X_train_temp[1:N_components,],X_test)
      rm(X_train_temp)

    }

  }

  i=index

  AllClasses.v <- unique(classInformation$Classes)
  ModList <- list()

  NewAnn <- ifelse(TrainPheno$Classes == AllClasses.v[[i]],"One","Others")

  print("Start Stan sampling")

  #Stan input for HS prior
  SCALE_ICEPT=10
  P0=min(c(parameter_P0,N_components-1))
  SIGMA_PSEUDO=1/sqrt(mean(ifelse(factor(NewAnn)=="One",1,0))*(1-mean(ifelse(factor(NewAnn)=="One",1,0))))
  SCALE_GLOBAL=(P0/(N_components-P0))*(SIGMA_PSEUDO/sqrt(ncol(X)))
  NU_GLOBAL=1
  NU_LOCAL=1
  SLAB_SCALE=2 #SLAB_SCALE and SLAB_DF values from https://rdrr.io/cran/brms/man/horseshoe.html where they are said to be the defaults
  SLAB_DF=4

  stan_input <- list(n=ncol(X),d=nrow(X),y=ifelse(factor(NewAnn)=="One",1,0),x=t(X),scale_icept=SCALE_ICEPT,scale_global=SCALE_GLOBAL,nu_global=NU_GLOBAL,nu_local=NU_LOCAL,slab_scale=SLAB_SCALE,slab_df=SLAB_DF)

  SM <- stan_model(STAN_FILE_NAME_LR_RHS)

  fit <- sampling(SM, data = stan_input, seed=123, iter=4000, control = list(adapt_delta=0.99))

  print(fit)
  warnings()

  if(pairsPlot==1){
    png(paste(FigFolder,"/pairs_plot_lr_RHS_PCA_class_",index,"_split_",dataSplitID,".png",sep=""))
    pairs(fit,pars = c("beta0","beta[1]","beta[2]","tau","lambda_tilde[1]","c","lp__"))
    dev.off()
  }


  la <- rstan::extract(fit, permuted = TRUE)

  predictions_train <-predict_class_LR_RHS(la,X)

  if(testSetPrediction==1){
    predictions_test <-predict_class_LR_RHS(la,X_test)
    testDataResults <- data.frame(trueClass = ifelse(TestPheno$Classes == AllClasses.v[[i]],1,0), trueClassName = TestPheno$Classes, predictedClass = predictions_test)
    

  } else {
    #If testSetPrediction=0 an empty data frame is stored
    testDataResults <- data.frame(TrueClass = integer(), trueClassName = character(), predictedClass = integer())
  }

  samples <- list(alpha=la$beta0, beta=la$beta)
  CombinedOutput_LR <- list(FittedModel = return_fitted_parameters_list_RHS(la), testDataResults = testDataResults, Samples = samples)
  return(CombinedOutput_LR)

}



#Function for running analysis with logistic regression with regularised horseshoe prior
train_LR_RHS_model <- function(DM, classInformation, TrainIndices, FeatureList,index,testSetPrediction=1,parameter_P0=300,pairsPlot=0,dataSplitID,FigFolder=NULL) {

  TrainData <- DM[,TrainIndices]
  TrainPheno <- classInformation[TrainIndices,]

  i=index
  Features <- FeatureList[[i]]

  X <- as.matrix(TrainData[rownames(TrainData) %in% Features,])
  X <- t(standardizecounts(X))

  if(testSetPrediction==1){
    TestData <- DM[,!colnames(DM) %in% TrainPheno$ID]
    TestPheno <- classInformation%>%filter(!ID %in% TrainPheno$ID)
    X_test <- as.matrix(TestData[rownames(TestData) %in% Features,])
    X_test <- t(standardizecounts_validation(as.matrix(TrainData[rownames(TrainData) %in% Features,]),X_test))
  }

  AllClasses.v <- unique(classInformation$Classes)
  ModList <- list()
  
  NewAnn <- ifelse(TrainPheno$Classes == AllClasses.v[[i]],"One","Others")


  #Stan input for HS prior
  SCALE_ICEPT=10
  #P0 should always be < length(unique(Features)) so that SCALE_GLOBAL will be a positive number (and not infinity)
  P0=min(c(parameter_P0,length(unique(Features))-1))
  SIGMA_PSEUDO=1/sqrt(mean(ifelse(factor(NewAnn)=="One",1,0))*(1-mean(ifelse(factor(NewAnn)=="One",1,0))))
  SCALE_GLOBAL=(P0/(length(unique(Features))-P0))*(SIGMA_PSEUDO/sqrt(ncol(TrainData)))
  NU_GLOBAL=1
  NU_LOCAL=1
  SLAB_SCALE=2 #SLAB_SCALE and SLAB_DF values from https://rdrr.io/cran/brms/man/horseshoe.html where they are said to be the defaults
  SLAB_DF=4
  stan_input <- list(n=ncol(TrainData),d=length(unique(Features)),y=ifelse(factor(NewAnn)=="One",1,0),x=X,scale_icept=SCALE_ICEPT,scale_global=SCALE_GLOBAL,nu_global=NU_GLOBAL,nu_local=NU_LOCAL,slab_scale=SLAB_SCALE,slab_df=SLAB_DF)

  SM <- stan_model(STAN_FILE_NAME_LR_RHS)

  fit <- sampling(SM, data = stan_input, seed=123, iter=2000)

  print(fit)
  warnings()

  if(pairsPlot==1){
    png(paste(FigFolder,"/pairs_plot_LR_RHS_class_",index,"_split_",dataSplitID,".png",sep=""))
    pairs(fit,pars = c("beta0","beta[1]","beta[2]","tau","lambda_tilde[1]","c","lp__"))
    dev.off()
  }

  la <- rstan::extract(fit, permuted = TRUE)

  if(testSetPrediction==1){
    predictions_test <-predict_class_LR_RHS(la,t(X_test))
    testDataResults <- data.frame(trueClass = ifelse(TestPheno$Classes == AllClasses.v[[i]],1,0), trueClassName = TestPheno$Classes, predictedClass = predictions_test)
  } else {
    #If testSetPrediction=0 an empty data frame is stored
    testDataResults <- data.frame(TrueClass = integer(), trueClassName = character(), predictedClass = integer())
  }  

  samples <- list(alpha=la$beta0, beta=la$beta)
  CombinedOutput_LR <- list(FittedModel = return_fitted_parameters_list_RHS(la), testDataResults = testDataResults, Samples = samples)

  return(CombinedOutput_LR)
}



#This function has been copied from MachineLearning_Final.html file from Ankur Chakravarthy. (2018). Machine Learning Models for cfMeDIP data from Shen et al. [Data set]. Zenodo. http://doi.org/10.5281/zenodo.1242697 Lisence: Creative Commons Attribution 4.0 International lisence
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

  


