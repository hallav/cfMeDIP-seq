
library(ggplot2)
library(cowplot)
library(RColorBrewer)
getPalette = colorRampPalette(brewer.pal(9, "Set1"))

plot_list_AUROC <- list()
plot_list_AUPRC <- list()
N_classes<-6
CLASSNAMES<-c("BrainMets" ,"Hemangiopericytoma","Meningioma","NE","WT.Glioma","MUT.Glioma")


METHODNAMES<-c("LR RHS","GLMNet","LR PCA","LR Fisher","LR DMRcount", "LR DMRcount F.", "LR ISPCA","LR bISPCA","GLMNet Fisher","GLMNet newT.","LR RHS newT.")
N_methods<-11

index<-1

INPUTFOLDER="..."

#Load data
load(paste(INPUTFOLDER,"/AUC_values_LR_RHS.RData",sep=""))
LR_RHS_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_Fisher.RData",sep=""))
LR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_DMRcount.RData",sep=""))
LR_DMR_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_PCA.RData",sep=""))
LR_PCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_DMRcount_Fisher.RData",sep=""))
LR_DMR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_ISPCA_multiclass.RData",sep=""))
LR_ISPCA_results <- AUC.median.df
load(paste(INPUTFOLDER,"/AUC_values_LR_ISPCA_binary.RData",sep=""))
LR_ISPCA_bin_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_newTransformation.RData",sep=""))
LR_RHS_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_newTransformation.RData",sep=""))
glmnet_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_Fisher.RData",sep=""))
glmnet_Fisher_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet.RData",sep=""))
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
                glmnet_Fisher_results$AUC_median[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUC_median[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUC_median[LR_RHS_newT_results$method=="ourMethod"]),
  auc_25=c(LR_RHS_results$AUC_25q[LR_RHS_results$method=="ourMethod"],
		glmnet_results$AUC_25q[glmnet_results$method=="glmnet"],
		LR_PCA_results$AUC_25q[LR_PCA_results$method=="ourMethod"],
		LR_Fisher_results$AUC_25q[LR_Fisher_results$method=="ourMethod"],
		LR_DMR_results$AUC_25q[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUC_25q[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUC_25q[LR_ISPCA_results$method=="ourMethod"],
		LR_ISPCA_bin_results$AUC_25q[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUC_25q[glmnet_Fisher_results$method=="glmnet"],
       	        glmnet_newT_results$AUC_25q[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUC_25q[LR_RHS_newT_results$method=="ourMethod"]),
  auc_75=c(LR_RHS_results$AUC_75q[LR_RHS_results$method=="ourMethod"],
		glmnet_results$AUC_75q[glmnet_results$method=="glmnet"],
		LR_PCA_results$AUC_75q[LR_PCA_results$method=="ourMethod"],
		LR_Fisher_results$AUC_75q[LR_Fisher_results$method=="ourMethod"],
		LR_DMR_results$AUC_75q[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUC_75q[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUC_75q[LR_ISPCA_results$method=="ourMethod"],
		LR_ISPCA_bin_results$AUC_75q[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUC_75q[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUC_75q[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUC_75q[LR_RHS_newT_results$method=="ourMethod"]))

plot_list_AUROC[[index]] <- ggplot(data=auc.data,aes(x=name, y=auc_median, fill=Method)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),size=0.2)+
  scale_fill_manual(values = getPalette(N_methods))+
  geom_errorbar(aes(ymin=auc_25, ymax=auc_75), position=position_dodge(.9), width=0.6, colour="orange", alpha=1, size=0.6)+
  ylim(0,1)+
  ylab("AUROC")+
  theme(axis.title.x=element_blank(),text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  theme(legend.key.size = unit(0.5, 'lines'))+
  theme(legend.key=element_blank(),legend.title = element_blank())

pr.auc.data <- data.frame(
  name=rep(CLASSNAMES,N_methods),
  Method=rep(METHODNAMES,each=N_classes),
  auc_median=c(LR_RHS_results$AUPRC_median[LR_RHS_results$method=="ourMethod"],
		glmnet_results$AUPRC_median[glmnet_results$method=="glmnet"],
		LR_PCA_results$AUPRC_median[LR_PCA_results$method=="ourMethod"],
		LR_Fisher_results$AUPRC_median[LR_Fisher_results$method=="ourMethod"],
		LR_DMR_results$AUPRC_median[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUPRC_median[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUPRC_median[LR_ISPCA_results$method=="ourMethod"],
		LR_ISPCA_bin_results$AUPRC_median[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUPRC_median[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUPRC_median[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUPRC_median[LR_RHS_newT_results$method=="ourMethod"]),
  auc_25=c(LR_RHS_results$AUPRC_25q[LR_RHS_results$method=="ourMethod"],
		glmnet_results$AUPRC_25q[glmnet_results$method=="glmnet"],
		LR_PCA_results$AUPRC_25q[LR_PCA_results$method=="ourMethod"],
		LR_Fisher_results$AUPRC_25q[LR_Fisher_results$method=="ourMethod"],
		LR_DMR_results$AUPRC_25q[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUPRC_25q[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUPRC_25q[LR_ISPCA_results$method=="ourMethod"],
		LR_ISPCA_bin_results$AUPRC_25q[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUPRC_25q[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUPRC_25q[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUPRC_25q[LR_RHS_newT_results$method=="ourMethod"]),
  auc_75=c(LR_RHS_results$AUPRC_75q[LR_RHS_results$method=="ourMethod"],
		glmnet_results$AUPRC_75q[glmnet_results$method=="glmnet"],
		LR_PCA_results$AUPRC_75q[LR_PCA_results$method=="ourMethod"],
		LR_Fisher_results$AUPRC_75q[LR_Fisher_results$method=="ourMethod"],
		LR_DMR_results$AUPRC_75q[LR_DMR_results$method=="ourMethod"],
                LR_DMR_Fisher_results$AUPRC_75q[LR_DMR_Fisher_results$method=="ourMethod"],
                LR_ISPCA_results$AUPRC_75q[LR_ISPCA_results$method=="ourMethod"],
		LR_ISPCA_bin_results$AUPRC_75q[LR_ISPCA_bin_results$method=="ourMethod"],
                glmnet_Fisher_results$AUPRC_75q[glmnet_Fisher_results$method=="glmnet"],
                glmnet_newT_results$AUPRC_75q[glmnet_newT_results$method=="glmnet"],
                LR_RHS_newT_results$AUPRC_75q[LR_RHS_newT_results$method=="ourMethod"]))


plot_list_AUPRC[[index]]<-ggplot(data=pr.auc.data,aes(x=name, y=auc_median, fill=Method)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),size=0.2)+
  scale_fill_manual(values = getPalette(N_methods))+
  geom_errorbar(aes(ymin=auc_25, ymax=auc_75), position=position_dodge(.9), width=0.6, colour="orange", alpha=1, size=0.6)+
  ylim(0,1)+
  ylab("AUPRC")+
  theme(axis.title.x=element_blank(),text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  theme(legend.key.size = unit(0.5, 'lines'))+
  theme(legend.key=element_blank(),legend.title = element_blank())

  p4<-ggplot(data=pr.auc.data,aes(x=name, y=auc_median, fill=Method)) +
    geom_bar(stat="identity", color="black", position=position_dodge(),size=0.2)+
    scale_fill_manual(values = getPalette(N_methods))+
    geom_errorbar(aes(ymin=auc_25, ymax=auc_75), position=position_dodge(.9), width=0.6, colour="orange",alpha=1, size=0.6)+
    ylim(0,1)+
    ylab("AUPRC")+
    theme(axis.title.x=element_blank(),text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
    theme(legend.key.size = unit(0.5, 'lines'))+
    theme(legend.key=element_blank(),legend.title = element_blank())

  legend_barplot_dicovery <- get_legend(p4)






library(extrafont)
loadfonts()
WIDTH_PDF<-6.69
HEIGHT_PDF<-3.4

#plot the figures in a grid
FIGFOLDER<-"..."
FIGNAME<-"intracranial_tumors_AUROC_barplots_170mm"


pdf(file=paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(plotlist=plot_list_AUROC,labels = NULL,label_size = 9, ncol = 1,scale = 0.9))
dev.off()
embed_fonts(paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""), outfile = paste(FIGFOLDER,"/",FIGNAME,"_embed.pdf",sep=""))


FIGNAME2<-"intracranial_tumors_AUPRC_barplots_170mm"


pdf(file=paste(FIGFOLDER,"/",FIGNAME2,".pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(plotlist=plot_list_AUPRC,labels = NULL,label_size = 9, ncol = 1,scale = 0.9))
dev.off()
embed_fonts(paste(FIGFOLDER,"/",FIGNAME2,".pdf",sep=""), outfile = paste(FIGFOLDER,"/",FIGNAME2,"_embed.pdf",sep=""))


