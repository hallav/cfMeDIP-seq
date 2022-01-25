
N_classes<-4
CLASSNAMES<-c("AML","LUC","PDAC","Normal")
METHODNAMES<-c("LR RHS","GLMNet","LR PCA","LR Fisher","LR DMRcount", "LR DMRcount F.", "LR ISPCA","LR bISPCA","GLMNet Fisher","GLMNet newT.","LR RHS newT.")
N_methods<-11

TABLEFOLDER <- ".../results/AUCs"

index<-1

for(THINNING in c(4,5,6)){

INPUTFOLDER=paste(".../results/AUCs/sameReadcount10_",THINNING,"_validation",sep="")

#Load data

load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS.RData",sep=""))
LR_RHS_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS_Fisher.RData",sep=""))
LR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_DMRcounts.RData",sep=""))
LR_DMR_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_DMRcounts_Fisher.RData",sep=""))
LR_DMR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS_PCA153_normalized.RData",sep=""))
LR_PCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_ISPCA_normalized.RData",sep=""))
LR_ISPCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_ISPCA_binary.RData",sep=""))
LR_ISPCA_bin_results <- AUC.median.df

load(paste(INPUTFOLDER,"/validation_AUC_values_glmnet_Fisher.RData",sep=""))
glmnet_Fisher_results <- AUC.median.df

load(paste(INPUTFOLDER,"/validation_AUC_values_glmnet_newTransformation.RData",sep=""))
glmnet_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/validation_AUC_values_glmnet.RData",sep=""))
glmnet_results <- AUC.median.df

load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS_newTransformation.RData",sep=""))
LR_RHS_newT_results <- AUC.median.df



auc.data <- data.frame(
  name=rep(CLASSNAMES,N_methods),
  Method=rep(METHODNAMES,each=N_classes),
  auc_median=c(LR_RHS_results$AUC_median[LR_RHS_results$method=="ourMethod"],
                glmnet_results$AUC_median[glmnet_results$method=="glmnet"],
                LR_PCA_results$AUC_median[LR_PCA_results$method=="ourMethod"],
                LR_Fisher_results$AUC_median[LR_Fisher_results$method=="ourMethod"],
                LR_DMR_results$AUC_median[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUC_median[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUC_median[LR_ISPCA_results$method=="ourMethod"],
                LR_ISPCA_bin_results$AUC_median[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUC_median[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUC_median[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUC_median[LR_RHS_newT_results$method=="ourMethod"]),
  auprc_median=c(LR_RHS_results$AUPRC_median[LR_RHS_results$method=="ourMethod"],
                glmnet_results$AUPRC_median[glmnet_results$method=="glmnet"],
                LR_PCA_results$AUPRC_median[LR_PCA_results$method=="ourMethod"],
                LR_Fisher_results$AUPRC_median[LR_Fisher_results$method=="ourMethod"],
                LR_DMR_results$AUPRC_median[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUPRC_median[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUPRC_median[LR_ISPCA_results$method=="ourMethod"],
                LR_ISPCA_bin_results$AUPRC_median[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUPRC_median[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUPRC_median[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUPRC_median[LR_RHS_newT_results$method=="ourMethod"]))

print(auc.data)



for(i in 1:N_classes){
  
  DM <- matrix(nrow=2,ncol=N_methods)
  
  for(j in 1:N_methods){
    
    DM[1,j] <- auc.data[(auc.data$name==CLASSNAMES[i])&(auc.data$Method==METHODNAMES[j]),"auc_median"]
    DM[2,j] <- auc.data[(auc.data$name==CLASSNAMES[i])&(auc.data$Method==METHODNAMES[j]),"auprc_median"]
  }
  
  rownames(DM) <- c("AUROC","AUPRC")
  colnames(DM) <- METHODNAMES
  
  write.table(round(DM,digits=3),sep="&",quote=FALSE,file=paste(TABLEFOLDER, "/thinned_validation_median_table_10_",THINNING,"_class_", CLASSNAMES[i],".txt",sep=""))

}

index <-index+1
}



