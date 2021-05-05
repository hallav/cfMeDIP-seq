#Script for plotting median AUC differences for validation cohort
#Note that the file and folder paths must be defined before running this script

#Folder where to store the figures
FIGFOLDER=### 

p1_list <-list()
p2_list <-list()

round <- 1

library(ggplot2)
library(cowplot)

for(THINNING in c(4,5,6)){


INPUTFOLDER=paste(".../sameReadcount10_",THINNING,"_validation",sep="")

#Load data

load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS.RData",sep=""))
LR_RHS_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS_Fisher.RData",sep=""))
LR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_DMRcounts.RData",sep=""))
LR_DMR_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_DMRcounts_Fisher.RData",sep=""))
LR_DMR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_RHS_PCA.RData",sep=""))
LR_PCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_ISPCA.RData",sep=""))
LR_ISPCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/validation_AUC_values_LR_ISPCA_DMR.RData",sep=""))
LR_ISPCA_DMR_results <- AUC.median.df
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



N_methods<-10
N_classes<-4
CLASSNAMES<-c("AML","LUC","PDAC","Normal")
METHODNAMES<-c("LR RHS","LR PCA","LR Fisher","LR DMRcount", "LR DMRcount F.", "LR ISPCA","LR bISPCA","GLMNet Fisher", "GLMNet newT.","LR RHS newT.")


auc.data <- data.frame(
  class=rep(CLASSNAMES,N_methods),
  method=rep(METHODNAMES,each=N_classes),
  auc_median=c(LR_RHS_results$AUC_median,
                LR_PCA_results$AUC_median,
		LR_Fisher_results$AUC_median,
		LR_DMR_results$AUC_median,
                LR_DMR_Fisher_results$AUC_median,
                LR_ISPCA_results$AUC_median,
		LR_ISPCA_bin_results$AUC_median,
                glmnet_Fisher_results$AUC_median,
                glmnet_newT_results$AUC_median,
                LR_RHS_newT_results$AUC_median),
  auc_25=c(LR_RHS_results$AUC_25q,
		LR_PCA_results$AUC_25q,
		LR_Fisher_results$AUC_25q,
		LR_DMR_results$AUC_25q,
                LR_DMR_Fisher_results$AUC_25q,
                LR_ISPCA_results$AUC_25q,
		LR_ISPCA_bin_results$AUC_25q,
                glmnet_Fisher_results$AUC_25q,
                glmnet_newT_results$AUC_25q,
                LR_RHS_newT_results$AUC_25q),
  auc_75=c(LR_RHS_results$AUC_75q,
		LR_PCA_results$AUC_75q,
		LR_Fisher_results$AUC_75q,
		LR_DMR_results$AUC_75q,
                LR_DMR_Fisher_results$AUC_75q,
                LR_ISPCA_results$AUC_75q,
		LR_ISPCA_bin_results$AUC_75q,
                glmnet_Fisher_results$AUC_75q,
                glmnet_newT_results$AUC_75q,
                LR_RHS_newT_results$AUC_75q),
  auc_median_diffToGlmnet=c(LR_RHS_results$AUC_median-glmnet_results$AUC_median,
                LR_PCA_results$AUC_median-glmnet_results$AUC_median,
                LR_Fisher_results$AUC_median-glmnet_results$AUC_median,
                LR_DMR_results$AUC_median-glmnet_results$AUC_median,
                LR_DMR_Fisher_results$AUC_median-glmnet_results$AUC_median,
                LR_ISPCA_results$AUC_median-glmnet_results$AUC_median,
                LR_ISPCA_bin_results$AUC_median-glmnet_results$AUC_median,
                glmnet_Fisher_results$AUC_median-glmnet_results$AUC_median,
                glmnet_newT_results$AUC_median-glmnet_results$AUC_median,
                LR_RHS_newT_results$AUC_median-glmnet_results$AUC_median))

auc.data$auc_median_diffToGlmnet[auc.data$auc_median_diffToGlmnet < -0.25] <- -0.25

#Store the legend from the first plot
if(THINNING==6){ 

  p3 <- ggplot(data=auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  theme(axis.text.x = element_text(angle = 45),text = element_text(size=7))+
  theme(legend.key.size = unit(0.5, 'lines'))+
  theme(legend.key=element_blank(),legend.title = element_blank())+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))
 


  legend_AUROC <- get_legend(p3)

  p1_list[[round]] <- ggplot(data=auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  labs(x=element_blank(),y=expression(paste("AUC-","AUC"[GLMNet])),col="Class")+
  theme(axis.text.x = element_text(angle = 45),legend.position="none",
	text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))
 


}else{

  p1_list[[round]] <- ggplot(data=auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  labs(y=expression(paste("AUC-","AUC"[GLMNet])),col="Class")+
  theme(axis.text.x = element_text(angle = 45),legend.position="none",
	text = element_text(size=7),axis.title.x=element_blank(),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))
 



}


pr.auc.data <- data.frame(
  class=rep(CLASSNAMES,N_methods),
  method=rep(METHODNAMES,each=N_classes),
  auc_median=c(LR_RHS_results$AUPRC_median,
		LR_PCA_results$AUPRC_median,
		LR_Fisher_results$AUPRC_median,
		LR_DMR_results$AUPRC_median,
                LR_DMR_Fisher_results$AUPRC_median,
                LR_ISPCA_results$AUPRC_median,
		LR_ISPCA_bin_results$AUPRC_median,
                glmnet_Fisher_results$AUPRC_median,
                glmnet_newT_results$AUPRC_median,
                LR_RHS_newT_results$AUPRC_median),
  auc_25=c(LR_RHS_results$AUPRC_25q,
		LR_PCA_results$AUPRC_25q,
		LR_Fisher_results$AUPRC_25q,
		LR_DMR_results$AUPRC_25q,
                LR_DMR_Fisher_results$AUPRC_25q,
                LR_ISPCA_results$AUPRC_25q,
		LR_ISPCA_bin_results$AUPRC_25q,
                glmnet_Fisher_results$AUPRC_25q,
                glmnet_newT_results$AUPRC_25q,
                LR_RHS_newT_results$AUPRC_25q),
  auc_75=c(LR_RHS_results$AUPRC_75q,
		LR_PCA_results$AUPRC_75q,
		LR_Fisher_results$AUPRC_75q,
		LR_DMR_results$AUPRC_75q,
                LR_DMR_Fisher_results$AUPRC_75q,
                LR_ISPCA_results$AUPRC_75q,
		LR_ISPCA_bin_results$AUPRC_75q,
                glmnet_Fisher_results$AUPRC_75q,
                glmnet_newT_results$AUPRC_75q,
                LR_RHS_newT_results$AUPRC_75q),
  auc_median_diffToGlmnet=c(LR_RHS_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_PCA_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_Fisher_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_DMR_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_DMR_Fisher_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_ISPCA_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_ISPCA_bin_results$AUPRC_median-glmnet_results$AUPRC_median,
                glmnet_Fisher_results$AUPRC_median-glmnet_results$AUPRC_median,
                glmnet_newT_results$AUPRC_median-glmnet_results$AUPRC_median,
                LR_RHS_newT_results$AUPRC_median-glmnet_results$AUPRC_median))

pr.auc.data$auc_median_diffToGlmnet[pr.auc.data$auc_median_diffToGlmnet < -0.25] <- -0.25

#Store the legend from the first plot
if(THINNING==6){

  p4 <- ggplot(data=pr.auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0)+
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  theme(axis.text.x = element_text(angle = 45),text = element_text(size=7))+
  theme(legend.key.size = unit(0.5, 'lines'))+
  theme(legend.key=element_blank(),legend.title = element_blank())+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))
 
  legend_AUPRC <- get_legend(p4)

  p2_list[[round]]<-ggplot(data=pr.auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  labs(x=element_blank(),y=expression(paste("AUC-","AUC"[GLMNet])),col="Class")+
  theme(axis.text.x = element_text(angle = 45),legend.position="none",
	text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))

}else{

  p2_list[[round]]<-ggplot(data=pr.auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  labs(y=expression(paste("AUC-","AUC"[GLMNet])),col="Class")+
  theme(axis.text.x = element_text(angle = 45),legend.position="none",
	text = element_text(size=7),axis.title.x=element_blank(),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))

}

round<-round+1

}

FIG_ID="truncated_noGPs_170mm_withMeans"
WIDTH_PDF<-6.69
HEIGHT_PDF<-5

#Make the AUPRC plot
pgrid1 <- plot_grid(plotlist=p2_list, ncol = 1,align='h',labels="AUTO",label_size=8,hjust=-0.2,vjust=1.3,scale = 0.9)
#plot and save the figure
pdf(file=paste(FIGFOLDER,"/validation_AUPRC_comparison_diffToGlmnet_",FIG_ID,".pdf",sep=""),width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(pgrid1, legend_AUPRC, rel_widths = c(7, 1),scale = 1))
dev.off()

#Make the AUROC plot
pgrid2 <- plot_grid(plotlist=p1_list, ncol = 1,align='h',labels="AUTO",label_size=8,hjust=-0.2,vjust=1.3,scale = 0.9)
#plot and save the figure
pdf(file=paste(FIGFOLDER,"/validation_AUROC_comparison_diffToGlmnet_",FIG_ID,".pdf",sep=""),width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(pgrid2, legend_AUROC, rel_widths = c(7, 1),scale = 1))
dev.off()

library(extrafont)
loadfonts()

embed_fonts(paste(FIGFOLDER,"/validation_AUPRC_comparison_diffToGlmnet_",FIG_ID,".pdf",sep=""), outfile = paste(FIGFOLDER,"/validation_AUPRC_comparison_diffToGlmnet_",FIG_ID,"_embed.pdf",sep=""))
embed_fonts(paste(FIGFOLDER,"/validation_AUROC_comparison_diffToGlmnet_",FIG_ID,".pdf",sep=""), outfile = paste(FIGFOLDER,"/validation_AUROC_comparison_diffToGlmnet_",FIG_ID,"_embed.pdf",sep=""))

