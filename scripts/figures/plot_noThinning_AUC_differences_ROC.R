#Script for plotting result figures for non-thinned data
#Note that file and folder paths must be defined before running this script

FIGFOLDER<-### Folder where figures are stored
library(pROC)
library(ggplot2)
library(cowplot)
library(RColorBrewer)
library(grid)
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
PLOT_list_of_lists <- list()

print("Begin making validation ROC curves")
INPUTFOLDER_VALIDATION<-### Folder where the information for plotting validation ROC curves is stored

#Load saved results for all methods and save into list

methodlist <- list()
methodnames <-c("LR RHS","LR PCA","LR Fisher","LR DMRcount", "LR DMRcount F", "LR ISPCA","LR bISPCA","LR RHS newT","GLMNet newT","GLMNet Fisher","GLMNet")
methodnames <-c("GLMNet","GLMNet Fisher","GLMNet newT.","LR bISPCA","LR DMRcount","LR DMRcount F.","LR Fisher","LR ISPCA","LR PCA","LR RHS","LR RHS newT.")
N_methods <- 11


load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_RHS.RData",sep=""))
methodlist[[10]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_PCA.RData",sep=""))
methodlist[[9]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_RHS_Fisher.RData",sep=""))
methodlist[[7]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_DMRcounts.RData",sep=""))
methodlist[[6]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_DMRcounts_Fisher.RData",sep=""))
methodlist[[5]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_ISPCA.RData",sep=""))
methodlist[[8]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_ISPCA_binary.RData",sep=""))
methodlist[[4]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_LR_RHS_newTransformation.RData",sep=""))
methodlist[[11]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_glmnet_Fisher.RData",sep=""))
methodlist[[2]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_glmnet_newTransformation.RData",sep=""))
methodlist[[3]] <- ROC_list

load(paste(INPUTFOLDER_VALIDATION,"/data_for_ROC_validation_glmnet.RData",sep=""))
methodlist[[1]] <- ROC_list


#Plot ROCs, store plots in lists

ROC_plotlist <- list()

for(CLASS in 1:4){

  ROC_objects<-list()

  #Calculate the TPR and FPR values
  for(M in 1:N_methods){

    currentmethod <- methodlist[[M]]
    currentclass <- currentmethod[[CLASS]]

    print(currentclass)

    ROC_objects[[M]]<-roc(currentclass$Classes,currentclass$Probability)


  }

  names(ROC_objects) <- methodnames

  ROC_plotlist[[CLASS]] <- ggroc(rev(ROC_objects),aes="color",legacy.axes=TRUE)+
                        scale_color_manual(values = rev(getPalette(N_methods)))+ 
			xlab("FPR") + 
			ylab("TPR") +
			geom_abline()+
			theme(legend.position="none",
			axis.text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"),
			axis.title=element_text(size=7),axis.text.x = element_text(angle = 45),
 			axis.title.y = element_text(margin = margin(t = 0, r = 0, b = 0, l = 0)),
 			axis.title.x = element_text(margin = margin(t = -0.5, r = 0, b = 0, l = 0)))+
 			coord_fixed()

  #Make one plot with legend and store it
    p_ROC <- ggroc(rev(ROC_objects),aes="color",legacy.axes=TRUE)+
                        scale_color_manual(values = rev(getPalette(N_methods)))+ 
			xlab("FPR") + 
			ylab("TPR") +
			geom_abline()+
			labs(color="Method")+
			theme(text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"),
                        legend.key.height= unit(0.3, 'cm'),legend.key.width= unit(0.3, 'cm'))+
                        theme(legend.position="bottom")+
                        theme(legend.title = element_blank())
                         
    legend_ROC <- get_legend(p_ROC)
}




#the validation ROC plot will be the bottom figure
PLOT_list_of_lists[[3]] <- ROC_plotlist


#Discovery cohort AUC difference plot
INPUTFOLDER<-### Folder where the discovery cohort AUC values are stored


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

load(paste(INPUTFOLDER,"/AUC_values_LR_RHS_newTransformation.RData",sep=""))
LR_RHS_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_newTransformation.RData",sep=""))
glmnet_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_Fisher.RData",sep=""))
glmnet_Fisher_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet.RData",sep=""))
glmnet_results <- AUC.median.df

N_methods<-10
N_classes<-8
CLASSNAMES<-c("AML","BRCA","CRC","PDAC","BLCA","Normal","LUC","RCC")
METHODNAMES<-c("LR RHS","LR PCA","LR Fisher","LR DMRcount", "LR DMRcount F.", "LR ISPCA","LR bISPCA","LR RHS newT.","GLMNet newT.","GLMNet Fisher")

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
                LR_RHS_newT_results$AUC_median,
                glmnet_newT_results$AUC_median,
                glmnet_Fisher_results$AUC_median),
  auc_25=c(LR_RHS_results$AUC_25q,
		LR_PCA_results$AUC_25q,
		LR_Fisher_results$AUC_25q,
		LR_DMR_results$AUC_25q,
                LR_DMR_Fisher_results$AUC_25q,
                LR_ISPCA_results$AUC_25q,
		LR_ISPCA_bin_results$AUC_25q,
       	       	LR_RHS_newT_results$AUC_25q,
       	        glmnet_newT_results$AUC_25q,
                glmnet_Fisher_results$AUC_25q),
  auc_75=c(LR_RHS_results$AUC_75q,
		LR_PCA_results$AUC_75q,
		LR_Fisher_results$AUC_75q,
		LR_DMR_results$AUC_75q,
                LR_DMR_Fisher_results$AUC_75q,
                LR_ISPCA_results$AUC_75q,
		LR_ISPCA_bin_results$AUC_75q,
                LR_RHS_newT_results$AUC_75q,
                glmnet_newT_results$AUC_75q,
                glmnet_Fisher_results$AUC_75q),
  auc_median_diffToGlmnet=c(LR_RHS_results$AUC_median-glmnet_results$AUC_median,
                LR_PCA_results$AUC_median-glmnet_results$AUC_median,
                LR_Fisher_results$AUC_median-glmnet_results$AUC_median,
                LR_DMR_results$AUC_median-glmnet_results$AUC_median,
                LR_DMR_Fisher_results$AUC_median-glmnet_results$AUC_median,
                LR_ISPCA_results$AUC_median-glmnet_results$AUC_median,
                LR_ISPCA_bin_results$AUC_median-glmnet_results$AUC_median,
                LR_RHS_newT_results$AUC_median-glmnet_results$AUC_median,
                glmnet_newT_results$AUC_median-glmnet_results$AUC_median,
                glmnet_Fisher_results$AUC_median-glmnet_results$AUC_median))

auc.data$auc_median_diffToGlmnet[auc.data$auc_median_diffToGlmnet < -0.25] <- -0.25 

  PLOT_list_of_lists[[1]]<- ggplot(data=auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  labs(x="Method",y=expression(paste("AUC-","AUC"[glmnet])),col="Class")+
  theme(axis.title.x = element_blank(),axis.text.x = element_text(angle = 45),text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  theme(legend.title = element_blank())+
  theme(legend.key.size = unit(0.5, 'lines'))+
  theme(legend.key=element_blank())+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))



#Validation AUROC comparison plot
INPUTFOLDER_VALIDATION<-### Folder where the validatio AUC values have been stored

#Load data

load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_RHS.RData",sep=""))
LR_RHS_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_RHS_Fisher.RData",sep=""))
LR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_DMRcounts.RData",sep=""))
LR_DMR_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_DMRcounts_Fisher.RData",sep=""))
LR_DMR_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_PCA.RData",sep=""))
LR_PCA_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_ISPCA.RData",sep=""))
LR_ISPCA_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_ISPCA_binary.RData",sep=""))
LR_ISPCA_bin_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_glmnet_Fisher.RData",sep=""))
glmnet_Fisher_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_glmnet_newTransformation.RData",sep=""))
glmnet_newT_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_glmnet.RData",sep=""))
glmnet_results <- AUC.median.df
load(paste(INPUTFOLDER_VALIDATION,"/validation_AUC_values_LR_RHS_newTransformation.RData",sep=""))
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


  PLOT_list_of_lists[[2]] <- ggplot(data=auc.data,aes(x=method, y=auc_median_diffToGlmnet)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(color=class),position = position_dodge(width =0.75),size=2)+
  ylim(-0.25,0.25)+
  labs(x=element_blank(),y=expression(paste("AUC-","AUC"[glmnet])),col="Class")+
  theme(axis.text.x = element_text(angle = 45),text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
  theme(legend.key.size = unit(0.5, 'lines'))+
  theme(legend.title = element_blank())+
  theme(legend.key=element_blank())+
  stat_summary(    geom = "point",
                   fun.data = mean_se,
                   col = "red",
                   size = 5,
                   aes(shape="Mean"),
                   fill = "red",
                   show.legend =NA)+
  scale_shape_manual("", values=c("Mean"="-"))



library(extrafont)

loadfonts()

WIDTH_PDF<-6.69
HEIGHT_PDF<-5.2


FIG_ID="withMeans"

CLASSNAMES_validation <- c("LUC","AML","Normal","PDAC")

bottom_row <- plot_grid(plotlist=PLOT_list_of_lists[[3]],labels=CLASSNAMES_validation,nrow=1,label_size=6,hjust=0,vjust=0,scale=0.975)
scattertop <- plot_grid(NULL,PLOT_list_of_lists[[1]],NULL,labels=c("","A",""),nrow=1,label_size=9,hjust=-0.2,vjust=0.5,rel_widths=c(1,5,1),scale=1)
scatterbottom <- plot_grid(NULL,PLOT_list_of_lists[[2]],NULL,labels=c("","B",""),nrow=1,label_size=9,hjust=-0.2,vjust=0.5,rel_widths=c(1,5,1),scale=1)
scatterPlots <- plot_grid(scattertop,scatterbottom,ncol=1)
bottom_row_legend <- plot_grid(bottom_row, legend_ROC, nrow=2, rel_heights= c(3,1), scale = c(0.95,0.1))

PLOT_grid <- plot_grid(scatterPlots,bottom_row_legend,labels = c("","C"),label_size = 9, ncol = 1,scale = 0.95,rel_heights=c(3,1.5))

pdf(file=paste(FIGFOLDER,"/noThinning_result_plots_",FIG_ID,".pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(PLOT_grid)
dev.off()
embed_fonts(paste(FIGFOLDER,"/noThinning_result_plots_",FIG_ID,".pdf",sep=""), outfile = paste(FIGFOLDER,"/noThinning_result_plots_",FIG_ID,"_embed.pdf",sep=""))

