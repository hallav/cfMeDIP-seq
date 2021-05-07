#Script for plotting validation cohort ROC curves
#Note that the file and folder paths must be defined before running this script

FIGFOLDER<-### Folder where the figures will be saved to
RESULTFOLDER<-### Folder where the data for plotting ROC curves has been stored to

library(pROC)
library(ggplot2)
library(cowplot)
library(RColorBrewer)
library(grid)
getPalette = colorRampPalette(brewer.pal(9, "Set1"))

ROC_list_of_lists <- list()
iter<-1

for(THINNING in c(4,5,6)){
INPUTFOLDER<-paste(RESULTFOLDER,"/totalReadcount10_",THINNING,"_validation",sep="")

#Load saved results for all methods and save into list

methodlist <- list()
methodnames <-c("GLMNet","GLMNet Fisher","GLMNet newT.","LR bISPCA","LR DMRcount","LR DMRcount F.","LR Fisher","LR ISPCA","LR PCA","LR RHS","LR RHS newT.")
N_methods <- 11


load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_RHS.RData",sep=""))
methodlist[[10]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_RHS.RData",sep=""))
methodlist[[9]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_RHS_Fisher.RData",sep=""))
methodlist[[7]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_DMRcounts.RData",sep=""))
methodlist[[5]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_DMRcounts_Fisher.RData",sep=""))
methodlist[[6]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_ISPCA.RData",sep=""))
methodlist[[8]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_ISPCA_binary.RData",sep=""))
methodlist[[4]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_LR_RHS_newTransformation.RData",sep=""))
methodlist[[11]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_glmnet_Fisher.RData",sep=""))
methodlist[[2]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_glmnet_newTransformation.RData",sep=""))
methodlist[[3]] <- ROC_list

load(paste(INPUTFOLDER,"/data_for_ROC_validation_glmnet.RData",sep=""))
methodlist[[1]] <- ROC_list


#Plot ROCs, store plots in lists

plotlist <- list()

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


  plotlist[[CLASS]] <- ggroc(rev(ROC_objects),aes="color",legacy.axes=TRUE)+ 
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
  if(THINNING==4 && CLASS==1){

    p4 <- ggroc(rev(ROC_objects),aes="color",legacy.axes=TRUE)+
                        scale_color_manual(values = rev(getPalette(N_methods)))+ 
			xlab("FPR") + 
			ylab("TPR") +
			geom_abline()+
			labs(color="Method")+
			theme(text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
                        theme(legend.position="bottom")+
                        theme(legend.title = element_blank())



    legend_ROC <- get_legend(p4)

  }

}


ROC_list_of_lists[[iter]] <- plotlist

iter<-iter+1
}



library(extrafont)

loadfonts()

WIDTH_PDF<-6.69
HEIGHT_PDF<-5.5


FIG_ID=""

CLASSNAMES <- c("LUC","AML","Normal","PDAC")

top_row <- plot_grid(plotlist=ROC_list_of_lists[[1]],labels=CLASSNAMES,nrow=1,label_size=6,hjust=0,vjust=0.1)
middle_row <- plot_grid(plotlist=ROC_list_of_lists[[2]],labels=CLASSNAMES,nrow=1,label_size=6,hjust=0,vjust=0.1)
bottom_row <- plot_grid(plotlist=ROC_list_of_lists[[3]],labels=CLASSNAMES,nrow=1,label_size=6,hjust=0,vjust=0.1)


ROC_grid <- plot_grid(top_row,middle_row,bottom_row,labels = "AUTO",label_size = 9, ncol = 1,scale = 0.9)

pdf(file=paste(FIGFOLDER,"/validation_ROC_",FIG_ID,".pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(ROC_grid, legend_ROC, nrow=2,rel_heights = c(3, .6),scale = c(1,0.75)))
dev.off()
embed_fonts(paste(FIGFOLDER,"/validation_ROC_",FIG_ID,".pdf",sep=""), outfile = paste(FIGFOLDER,"/validation_ROC_",FIG_ID,"_embed.pdf",sep=""))




