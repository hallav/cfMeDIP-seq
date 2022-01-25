library(ggplot2)
library(cowplot)
library(RColorBrewer)
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
plot_list_AUROC <- list()
plot_list_AUPRC <- list()
N_classes<-8
CLASSNAMES<-c("AML","BRCA","CRC","PDAC","BLCA","Normal","LUC","RCC")

METHODNAMES<-c("GLMNet newT. 100","GLMNet newT. 300", "GLMNet newT. 400", "GLMNet Fisher 100", "GLMNet Fisher 300", "GLMNet Fisher 400")
N_methods <- 6
TABLEFOLDER<-".../results/AUCs"

index<-1
for(THINNING in c(4,5,6)){

INPUTFOLDER=paste("/results/AUCs/sameReadcount10_",THINNING,"/wF1AndAccuracy",sep="")

#Load data

load(paste(INPUTFOLDER,"/AUC_values_glmnet_Fisher_fixed.RData",sep=""))
glmnet_Fisher_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_Fisher_featureN50.RData",sep=""))
glmnet_Fisher_N50_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_Fisher_featureN200.RData",sep=""))
glmnet_Fisher_N200_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_newTransformation_fixed.RData",sep=""))
glmnet_newT_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_newTransformation_featureN200.RData",sep=""))
glmnet_newT_N200_results <- AUC.median.df

load(paste(INPUTFOLDER,"/AUC_values_glmnet_newTransformation_featureN50.RData",sep=""))
glmnet_newT_N50_results <- AUC.median.df


auc.data <- data.frame(
  name=rep(CLASSNAMES,N_methods),
  Method=rep(METHODNAMES,each=N_classes),
  auc_median=c(glmnet_newT_N50_results$AUC_median[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUC_median[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUC_median[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUC_median[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUC_median[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUC_median[glmnet_Fisher_N200_results$method=="glmnet"]),
  auc_25=c(glmnet_newT_N50_results$AUC_25q[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUC_25q[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUC_25q[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUC_25q[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUC_25q[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUC_25q[glmnet_Fisher_N200_results$method=="glmnet"]),
  auc_75=c(glmnet_newT_N50_results$AUC_75q[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUC_75q[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUC_75q[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUC_75q[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUC_75q[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUC_75q[glmnet_Fisher_N200_results$method=="glmnet"]))




plot_list_AUROC[[index]] <- ggplot(data=auc.data,aes(x=name, y=auc_median, fill=Method)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),size=0.2)+
  scale_fill_manual(values = getPalette(N_methods))+
  geom_errorbar(aes(ymin=auc_25, ymax=auc_75), position=position_dodge(.9), width=0.6, colour="orange", alpha=1, size=0.6)+
  ylim(0,1)+
  ylab("AUROC")+
  theme(axis.title.x=element_blank(),legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))


pr.auc.data <- data.frame(
  name=rep(CLASSNAMES,N_methods),
  Method=rep(METHODNAMES,each=N_classes),
  auc_median=c(glmnet_newT_N50_results$AUPRC_median[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUPRC_median[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUPRC_median[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUPRC_median[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUPRC_median[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUPRC_median[glmnet_Fisher_N200_results$method=="glmnet"]),
  auc_25=c(glmnet_newT_N50_results$AUPRC_25q[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUPRC_25q[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUPRC_25q[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUPRC_25q[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUPRC_25q[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUPRC_25q[glmnet_Fisher_N200_results$method=="glmnet"]),
  auc_75=c(glmnet_newT_N50_results$AUPRC_75q[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUPRC_75q[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUPRC_75q[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUPRC_75q[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUPRC_75q[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUPRC_75q[glmnet_Fisher_N200_results$method=="glmnet"]))



plot_list_AUPRC[[index]]<-ggplot(data=pr.auc.data,aes(x=name, y=auc_median, fill=Method)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),size=0.2)+
  scale_fill_manual(values = getPalette(N_methods))+
  geom_errorbar(aes(ymin=auc_25, ymax=auc_75), position=position_dodge(.9), width=0.6, colour="orange", alpha=1, size=0.6)+
  ylim(0,1)+
  ylab("AUPRC")+
  theme(axis.title.x=element_blank(),legend.position="none",text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))

if(index==3){
  p4<-ggplot(data=pr.auc.data,aes(x=name, y=auc_median, fill=Method)) +
    geom_bar(stat="identity", color="black", position=position_dodge(),size=0.2)+
    scale_fill_manual(values = getPalette(N_methods))+
    geom_errorbar(aes(ymin=auc_25, ymax=auc_75), position=position_dodge(.9), width=0.6, colour="orange",alpha=1, size=0.6)+
    ylim(0,1)+
    ylab("AUPRC")+
    theme(axis.title.x=element_blank(),text = element_text(size=7),plot.margin = unit(c(0, 0, 0, 0), "cm"))+
    theme(legend.key.size = unit(0.5, 'lines'))+
    theme(legend.key=element_blank(),legend.title = element_blank())

  legend_barplot <- get_legend(p4)

}



auc.data <- data.frame(
  name=rep(CLASSNAMES,N_methods),
  Method=rep(METHODNAMES,each=N_classes),
  auc_median=c(glmnet_newT_N50_results$AUC_median[glmnet_newT_N50_results$method=="glmnet"],
               glmnet_newT_results$AUC_median[glmnet_newT_results$method=="glmnet"],
               glmnet_newT_N200_results$AUC_median[glmnet_newT_N200_results$method=="glmnet"],
               glmnet_Fisher_N50_results$AUC_median[glmnet_Fisher_N50_results$method=="glmnet"],
               glmnet_Fisher_results$AUC_median[glmnet_Fisher_results$method=="glmnet"],
               glmnet_Fisher_N200_results$AUC_median[glmnet_Fisher_N200_results$method=="glmnet"]),
  auprc_median=c(glmnet_newT_N50_results$AUPRC_median[glmnet_newT_N50_results$method=="glmnet"],
                 glmnet_newT_results$AUPRC_median[glmnet_newT_results$method=="glmnet"],
                 glmnet_newT_N200_results$AUPRC_median[glmnet_newT_N200_results$method=="glmnet"],
                 glmnet_Fisher_N50_results$AUPRC_median[glmnet_Fisher_N50_results$method=="glmnet"],
                 glmnet_Fisher_results$AUPRC_median[glmnet_Fisher_results$method=="glmnet"],
                 glmnet_Fisher_N200_results$AUPRC_median[glmnet_Fisher_N200_results$method=="glmnet"]))

print(auc.data)



for(i in 1:N_classes){
  
  DM <- matrix(nrow=2,ncol=N_methods)
  
  for(j in 1:N_methods){
       
    DM[1,j] <- auc.data[(auc.data$name==CLASSNAMES[i])&(auc.data$Method==METHODNAMES[j]),"auc_median"]
    DM[2,j] <- auc.data[(auc.data$name==CLASSNAMES[i])&(auc.data$Method==METHODNAMES[j]),"auprc_median"]
  }
  
  rownames(DM) <- c("AUROC","AUPRC")
  colnames(DM) <- METHODNAMES
  
  write.table(round(DM,digits=3),sep="&",quote=FALSE,file=paste(TABLEFOLDER, "/featureNcomparison_discovery_median_table_10_",THINNING,"class_", CLASSNAMES[i],".txt",sep=""))

}

index <-index+1
}

library(extrafont)

loadfonts()

WIDTH_PDF<-6.69
HEIGHT_PDF<-4

#plot the figures in a grid
FIGFOLDER<-".../results/AUCs"
FIGNAME<-"AUROC_barplots_discovery_featureNcomparison_170mm"

barplot_grid <- plot_grid(plotlist=plot_list_AUROC,labels = "AUTO",label_size = 9, ncol = 1,scale = 0.9)

pdf(file=paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(barplot_grid, legend_barplot, ncol=2,scale = c(1,1),rel_widths=c(6,1)))
dev.off()
embed_fonts(paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""), outfile = paste(FIGFOLDER,"/",FIGNAME,"_embed.pdf",sep=""))


FIGNAME<-"AUPRC_barplots_discovery_featureNcomparison_170mm"

barplot_grid2 <- plot_grid(plotlist=plot_list_AUPRC,labels = "AUTO",label_size = 9, ncol = 1,scale = 0.9)

pdf(file=paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""),
    width = WIDTH_PDF, height = HEIGHT_PDF)
ggdraw(plot_grid(barplot_grid2, legend_barplot, ncol=2,scale = c(1,1),rel_widths=c(6,1)))
dev.off()
embed_fonts(paste(FIGFOLDER,"/",FIGNAME,".pdf",sep=""), outfile = paste(FIGFOLDER,"/",FIGNAME,"_embed.pdf",sep=""))


