library(ggplot2)
library(cowplot)
library(RColorBrewer)
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
plot_list_AUROC <- list()
plot_list_AUPRC <- list()
N_classes<-8
CLASSNAMES<-c("AML","BRCA","CRC","PDAC","BLCA","Normal","LUC","RCC")
METHODNAMES<-c("LR RHS","GLMNet","LR PCA","LR Fisher","LR DMRcount", "LR DMRcount F.", "LR ISPCA","LR bISPCA","LR RHS newT.","GLMNet newT.","GLMNet Fisher")
N_methods<-11

TABLEFOLDER<-".../results/AUCs"


index<-1
for(THINNING in c(4,5,6)){

INPUTFOLDER=paste(".../results/AUCs/sameReadcount10_",THINNING,sep="")

#Load data

load(paste(INPUTFOLDER,"/AUC_values_LR_RHS.RData",sep=""))
LR_RHS_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_Fisher.RData",sep=""))
LR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_DMRcount.RData",sep=""))
LR_DMR_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_PCA.RData",sep=""))
LR_PCA_results <- AUC.median.df 
load(paste(INPUTFOLDER,"/AUC_values_LR_DMRcount_Fisher.RData",sep=""))
LR_DMR_Fisher_results <- AUC.median.df 
load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_ISPCA.RData",sep=""))
LR_ISPCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_ISPCA_binary.RData",sep=""))
LR_ISPCA_bin_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_newTransformaton.RData",sep=""))
LR_RHS_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_newTransformation_fixed.RData",sep=""))
glmnet_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_Fisher_fixed.RData",sep=""))
glmnet_Fisher_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_fixed.RData",sep=""))
glmnet_results <- AUC.median.df


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
                LR_RHS_newT_results$AUC_median[LR_RHS_newT_results$method=="ourMethod"],
                glmnet_newT_results$AUC_median[glmnet_newT_results$method=="glmnet"],
                glmnet_Fisher_results$AUC_median[glmnet_Fisher_results$method=="glmnet"]),
  auprc_median=c(LR_RHS_results$AUPRC_median[LR_RHS_results$method=="ourMethod"],
                glmnet_results$AUPRC_median[glmnet_results$method=="glmnet"],
                LR_PCA_results$AUPRC_median[LR_PCA_results$method=="ourMethod"],
                LR_Fisher_results$AUPRC_median[LR_Fisher_results$method=="ourMethod"],
                LR_DMR_results$AUPRC_median[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUPRC_median[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUPRC_median[LR_ISPCA_results$method=="ourMethod"],
                LR_ISPCA_bin_results$AUPRC_median[LR_ISPCA_bin_results$method=="ourMethod"],
                LR_RHS_newT_results$AUPRC_median[LR_RHS_newT_results$method=="ourMethod"],
                glmnet_newT_results$AUPRC_median[glmnet_newT_results$method=="glmnet"],
                glmnet_Fisher_results$AUPRC_median[glmnet_Fisher_results$method=="glmnet"]))

print(auc.data)

for(i in 1:N_classes){
  
  DM <- matrix(nrow=2,ncol=N_methods)
  
  for(j in 1:N_methods){
   
    
    DM[1,j] <- auc.data[(auc.data$name==CLASSNAMES[i])&(auc.data$Method==METHODNAMES[j]),"auc_median"]
    DM[2,j] <- auc.data[(auc.data$name==CLASSNAMES[i])&(auc.data$Method==METHODNAMES[j]),"auprc_median"]
  }
  
  rownames(DM) <- c("AUROC","AUPRC")
  colnames(DM) <- METHODNAMES
  
  write.table(round(DM,digits=3),sep="&",quote=FALSE,file=paste(TABLEFOLDER, "/thinned_discovery_median_table_10_",THINNING,"_class_", CLASSNAMES[i],".txt",sep=""))
  
}


index <-index+1
}


